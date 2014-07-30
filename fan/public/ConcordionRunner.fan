using fandoc
using afBeanUtils
using afPlastic
using concurrent

** Runs Concordion fixtures.
class ConcordionRunner {
	private static const Log log		:= Utils.getLog(ConcordionRunner#)
	
	** Where the generated HTML result files are saved.
	File		outputDir				:= Env.cur.tempDir + `concordion/`
	
	** The skin applied to generated HTML result files.
	Type		skinType				:= ClassicSkin#
	
	** The commands made available to Concordion tests. 
	Str:Command	commands				:= Str:Command[:] { caseInsensitive = true }

	** A command chain of 'SpecificationFinders'.
	@NoDoc
	SpecificationFinder[] specFinders	:= SpecificationFinder[,]
		
	** Creates a 'ConcordionRunner'.
	new make(|This|? f := null) {
		commands["verify"]	= CmdVerify()
		commands["set"]		= CmdSet()
		commands["execute"]	= CmdExecute()
		commands["fail"]	= CmdFail()
		commands["run"]		= CmdRun()
		commands["embed"]	= CmdEmbed()
		commands["http"]	= CmdLink()
		commands["https"]	= CmdLink()
		commands["mailto"]	= CmdLink()
		commands["file"]	= CmdLink()
		
		specFinders.add(FindSpecFromFacetValue())
		specFinders.add(FindSpecFromTypeFandoc())
		specFinders.add(FindSpecFromSrcFile())
		specFinders.add(FindSpecFromPodFile())

		f?.call(this)
	}

	** Runs the given Concordion fixture.
	FixtureResult runFixture(Obj fixtureInstance) {
		// we need the fixture *instance* so it can have any state, 
		// and if a Test instance, verify cmd uses it to notch up the verify count
		
		if (!fixtureInstance.typeof.hasFacet(Fixture#))
			throw ArgErr(ErrMsgs.fixtureFacetNotFound(fixtureInstance.typeof))

		locals := Locals.instance
		firstFixture := (locals.originalRunner == null) 
		if (firstFixture) {
			locals.originalRunner = this
			suiteSetup()

			// when multiple tests (e.g. a pod) are run with fant we have NO way of knowing which is 
			// the last test because sadly fant has no hooks. So for a clean teardown the best we can
			// do is a shutdown hook.
			// AND Actor.locals() has been cleaned up by the time we get here, so we need to keep our
			// own references.
			safeRunner 	 := Unsafe(locals.originalRunner)
			safeResults	 := Unsafe(locals.resultsCache)
			shutdownHook := |->| { 
				((ConcordionRunner) safeRunner.val).suiteTearDown(safeResults.val)
				Locals.instance.shutdownHook = null
				Locals.instance.resultsCache = null
			}
			Env.cur.addShutdownHook(shutdownHook)
			
			// stick the hook in Actor locals in case someone wants to remove it
			locals.shutdownHook = shutdownHook
		}
		
		
		// don't run tests twice - e.g. from fant and from a `run:cmd`
		if (locals.resultsCache.containsKey(fixtureInstance.typeof)) {
			log.info("Fixture '${fixtureInstance.typeof.qname}' has already been run - Skipping...")
			return locals.resultsCache[fixtureInstance.typeof]
		}


		// a small hook so Test classes can notch up extra verify counts.
		if (fixtureInstance is Test)
			Actor.locals["afBounce.testInstance"] = fixtureInstance
		
		
		startTime	:= DateTime.now(null)
		specMeta	:= SpecificationFinders(specFinders).findSpecification(fixtureInstance.typeof)
		doc			:= FandocParser().parseStr(specMeta.specificationSrc)
		docTitle	:= doc.findHeadings.first?.title ?: specMeta.fixtureType.name.fromDisplayName
		podName		:= specMeta.fixtureType.pod?.name ?: "no-name"
		
		if (podName.contains("_"))	podName = "no-name"	// scripts are called `FileName_0`
		outputDir.createDir(podName)
		resultFile	:= this.outputDir.plus(podName.toUri, false) + `${fixtureInstance.typeof.name}.html` 
		
		fixMeta		:= FixtureMeta() {
			it.title			= docTitle
			it.fixtureType		= specMeta.fixtureType
			it.specificationLoc	= specMeta.specificationLoc
			it.specificationSrc	= specMeta.specificationSrc
			it.baseOutputDir	= this.outputDir
			it.resultFile		= resultFile
			it.StartTime		= startTime
		}
		
		fixCtx		:= FixtureCtx() {
			it.fixtureInstance	= fixtureInstance
			it.skin				= gimmeSomeSkin
			it.renderBuf		= StrBuf(specMeta.specificationSrc.size * 2)
			it.errs				= Err[,]
		}
		
		try {
			ThreadStack.push("afConcordion.runner", this)
			ThreadStack.push("afConcordion.fixtureMeta", fixMeta)
			ThreadStack.push("afConcordion.fixtureCtx", fixCtx)
					
			fixtureSetup(fixtureInstance)
			
			resultHtml := (Str?) null
			try {
				resultHtml	= renderFixture(doc, fixCtx)	// --> RUN THE TEST!!!
			} catch (Err err) {
				fixCtx.errs.add(err)
				resultHtml = errorPage(fixMeta, err)
			}
			
			resultFile.out.print(resultHtml).close
						
			result := FixtureResult {
				it.fixtureMeta	= fixMeta
				it.resultHtml	= resultHtml
				it.resultFile 	= resultFile
				it.errors		= fixCtx.errs
				it.timestamp	= DateTime.now(null)
				it.duration		= startTime - it.timestamp
			}
			
			// cache the result so we can short-circuit should it called again
			locals.resultsCache[fixtureInstance.typeof] = result

			fixtureTearDown(fixtureInstance, result)

			return result
			
		} finally {
			ThreadStack.pop("afConcordion.runner")
			ThreadStack.pop("afConcordion.fixtureMeta")
			ThreadStack.pop("afConcordion.fixtureCtx")
			
			// no too bother if this never gets cleaned up
			Actor.locals.remove("afBounce.testInstance")
		}
	}
	
	** Called before the first fixture is run.
	** 
	** By default this empties the output dir. 
	virtual Void suiteSetup() {
		// wipe the slate clean to begin with
		try {
			outputDir.delete
			outputDir.create

		} catch (Err err) {
			msg := "\n"
			msg += "*******************************************************************************"
			msg += "** ${err.msg}"
			msg += "*******************************************************************************"
			msg += "\n"
			log.warn(msg)
		}
	}

	** Called after the last fixture has run.
	** 
	** By default does nothing. 
	virtual Void suiteTearDown(Type:FixtureResult resultsCache) {
		indexFile := outputDir + `index.html`
		if (!indexFile.exists && !resultsCache.isEmpty) {
			url := resultsCache.vals.first.resultFile.uri.relTo(outputDir.uri)
			indexFile.out.print("""<html><head><meta http-equiv="refresh" content="0; url=${url.encode.toXml}" /></head></html>""").close
		}
	}

	** Called before every fixture.
	** 
	** By default does nothing. 
	virtual Void fixtureSetup(Obj fixtureInstance) { }

	** Called after every fixture.
	** 
	** By default prints the location of the result file. 
	virtual Void fixtureTearDown(Obj fixtureInstance, FixtureResult result) {
		// TODO: print something better
		log.info(result.resultFile.normalize.osPath)		
	}
	
	** A hook that creates an 'ConcordionSkin' instance.
	** 
	** Simply returns 'skinType.make()' by default.
	virtual ConcordionSkin gimmeSomeSkin() {
		skinType.make
	}
	
	** Rendered when a Fixture fails for an unknown reason - usually due to an error in the skin.
	** 
	** By default this just renders the stack trace.
	virtual Str errorPage(FixtureMeta fixMeta, Err err) { 
"""<!DOCTYPE html>
   <html xmlns="http://www.w3.org/1999/xhtml">
   <head>
   	<title>${fixMeta.title.toXml} : Concordion</title>
   </head>
   <body>
   <pre>
   ${err.traceToStr}
   </pre>
   </body>
   </html>
   """
	}
	
	private Str renderFixture(Doc doc, FixtureCtx fixCtx) {
		cmds := Commands(commands)
		fdw	 := FixtureDocWriter(cmds, fixCtx)
		fixCtx.skin.setup
		try {
			fdw.docStart(doc)
			doc.writeChildren(fdw)
			fdw.docEnd(doc)
		} finally
			fixCtx.skin.tearDown
		return fixCtx.renderBuf.toStr			
	}
}
