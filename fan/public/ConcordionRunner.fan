using fandoc
using afBeanUtils
using afPlastic

** Runs Concordion fixtures.
class ConcordionRunner {
	private static const Log log	:= Utils.getLog(ConcordionRunner#)
	
	** Where the generated HTML result files are saved.
	File		outputDir		:= Env.cur.tempDir + `concordion/`
	
	** The skin applied to generated HTML result files.
	Type		skinType		:= ClassicSkin#
	
	** The commands made available to Concordion tests. 
	Str:Command	commands		:= Str:Command[:] { caseInsensitive = true }
		
	** Creates a 'ConcordionRunner'.
	new make(|This|? f := null) {
		commands["verify"]	= CmdVerify()
		commands["set"]		= CmdSet()
//		commands["execute"]	= CmdExecute()	// FIXME: execute command
		commands["http"]	= CmdLink()
		commands["https"]	= CmdLink()
		commands["file"]	= CmdLink()
		commands["test"]	= CmdTest()

		f?.call(this)
	}

	** Runs the given Concordion fixture.
	FixtureResult runFixture(Obj fixtureInstance) {
		// we need the fixture *instance* so it can have any state, 
		// and if a Test instance, verify cmd uses it to notch up the verify count

		locals := Locals.instance
		
		if (!fixtureInstance.typeof.hasFacet(Fixture#))
			throw ArgErr(ErrMsgs.fixtureFacetNotFound(fixtureInstance.typeof))		

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
		
		
		// don't run tests twice - e.g. from fant and from a `test:cmd`
		if (locals.resultsCache.containsKey(fixtureInstance.typeof))
			return locals.resultsCache[fixtureInstance.typeof]

		
		startTime	:= DateTime.now(null)
		specMeta	:= SpecificationFinder().findSpecification(fixtureInstance.typeof)
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
					
			fixtureSetup()
			
			resultHtml := (Str?) null
			try {
				resultHtml	= renderFixture(doc, fixCtx)	// --> RUN THE TEST!!!
			} catch (Err err) {
				fixCtx.errs.add(err)
				resultHtml = fixCtx.skin.errorPage(err)
			}
			
			resultFile.out.print(resultHtml).close
						
			result := FixtureResult {
				it.fixtureMeta	= fixMeta
				it.resultHtml	= resultHtml
				it.resultFile 	= resultFile
				it.errors		= fixCtx.errs
			}
			
			// cache the result so we can short-circuit should it called again
			locals.resultsCache[fixtureInstance.typeof] = result

			fixtureTearDown(result)

			return result
			
		} finally {
			ThreadStack.pop("afConcordion.runner")
			ThreadStack.pop("afConcordion.fixtureMeta")
			ThreadStack.pop("afConcordion.fixtureCtx")
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
			Env.cur.err.printLine
			Env.cur.err.printLine("*******************************************************************************")
			Env.cur.err.printLine("** ${err.msg}")
			Env.cur.err.printLine("*******************************************************************************")
			Env.cur.err.printLine
		}
	}

	** Called after the last fixture has run.
	** 
	** By default does nothing. 
	virtual Void suiteTearDown(Type:FixtureResult resultsCache) {
		indexFile := outputDir + `index.html`
		if (!indexFile.exists) {
			url := resultsCache.vals.first.resultFile.uri.relTo(outputDir.uri)
			indexFile.out.print("""<html><head><meta http-equiv="refresh" content="0; url=${url.encode.toXml}" /></head></html>""").close
		}
	}

	** Called before every fixture.
	** 
	** By default does nothing. 
	virtual Void fixtureSetup() { }

	** Called after every fixture.
	** 
	** By default prints the location of the result file. 
	virtual Void fixtureTearDown(FixtureResult result) {
		// TODO: print something better
		log.info(result.resultFile.normalize.osPath)		
	}
	
	** A hook that creates an 'ConcordionSkin' instance.
	** 
	** Simply returns 'skinType.make()' by default.
	virtual ConcordionSkin gimmeSomeSkin() {
		skinType.make
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
