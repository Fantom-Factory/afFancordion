using fandoc
using afBeanUtils
using concurrent

** Runs Fancordion fixtures.
class FancordionRunner {
	private static const Log log		:= Utils.getLog(FancordionRunner#)
	
	** Where the generated HTML result files are saved.
	File		outputDir				:= Env.cur.tempDir + `fancordion/`
	
	** The skin applied to generated HTML result files.
	** 
	** Defaults to `ClassicSkin`.
	Type		skinType				:= ClassicSkin#
	
	// This way there is a clean separation between the cmd and key func 
	** The commands made available to Fancordion tests.
	** 
	** The key may either be a 'Str' (that matches the URI scheme) or an immutable func of '|Str cmdUrl->Bool|'.  
	Obj:Command	commands				:= Obj:Command[:]

	** A command chain of 'SpecificationFinders'.
	@NoDoc
	SpecificationFinder[] specFinders	:= SpecificationFinder[,]

	** A hook that creates an 'FancordionSkin' instance.
	** 
	** Simply returns 'skinType.make()' by default.
	|->FancordionSkin| gimmeSomeSkin	:= |->FancordionSkin| { skinType.make }
	
	** Section functions determine which headings correspond to sections and should be wrapped in a special border. 
	** The default function checks if the heading starts with the word *Example*:
	** 
	**   syntax: fantom
	**   runner.sectionFuncs.add(
	**       |Str heading, Int level->Bool| {
	**           heading.lower.startsWith("example") 
	**       }
	**   )
	|Str, Int->Bool|[] sectionFuncs		:= |Str, Int->Bool|[,]
	
	** Creates a 'FancordionRunner'.
	new make() {
		commands["verifyEq"]		= CmdVerify("verifyEq")
		commands["verifyNotEq"]		= CmdVerify("verifyNotEq")
		commands["verifyType"]		= CmdVerify("verifyType")
		commands["verify"]			= CmdVerify("verify")
		commands["verifyTrue"]		= CmdVerify("verify")
		commands["verifyFalse"]		= CmdVerify("verifyFalse")
		commands["verifyNull"]		= CmdVerify("verifyNull")
		commands["verifyNotNull"]	= CmdVerify("verifyNotNull")
		commands["verifyErrType"]	= CmdVerifyErrType()
		commands["verifyErrMsg"]	= CmdVerifyErrMsg()
		commands["set"]				= CmdSet()
		commands["execute"]			= CmdExecute()
		commands["fail"]			= CmdFail()
		commands["run"]				= CmdRun()
		commands["table"]			= CmdTable()
		commands["embed"]			= CmdEmbed()
		commands["link"]			= CmdLink()
		commands["http"]			= CmdLink()
		commands["https"]			= CmdLink()
		commands["mailto"]			= CmdLink()
		commands["file"]			= CmdLink()
		commands["fandoc"]			= CmdFandoc()
		commands["todo"]			= CmdIgnore()

		commands[|Str cmdUrl->Bool| {
			cmdUrl.startsWith("#")
		}.toImmutable] = CmdLink()

		commands[|Str cmdUrl->Bool| {
			cmdUrl.contains("::") && cmdUrl.all { it.isAlphaNum || it == ':' }
		}.toImmutable] = CmdFandoc()

		// add shortcut aliases
		commands["eq"]		= commands["verifyEq"]
		commands["notEq"]	= commands["verifyNotEq"]
		commands["type"]	= commands["verifyType"]
		commands["true"]	= commands["verifyTrue"]
		commands["false"]	= commands["verifyFalse"]
		commands["null"]	= commands["verifyNull"]
		commands["notNull"]	= commands["verifyNotNull"]
		commands["errType"]	= commands["verifyErrType"]
		commands["errMsg"]	= commands["verifyErrMsg"]
		commands["exe"]		= commands["execute"]

		specFinders.add(FindSpecFromFacetValue())
		specFinders.add(FindSpecFromTypeFandoc())
		specFinders.add(FindSpecFromTypeInSrcFile())
		specFinders.add(FindSpecFromTypeInPodFile())
		specFinders.add(FindSpecInPodFile())
		specFinders.add(FindSpecOnFileSystem())
		
		sectionFuncs.add(
			|Str heading, Int level->Bool| { heading.lower.startsWith("example") }
		)
	}

	** Runs the given Fancordion fixture.
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
				((FancordionRunner) safeRunner.val).suiteTearDown(safeResults.val)
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
		
		if (specMeta.fixtureType.pod != null)
			if (specMeta.fixtureType.pod.meta["pod.isScript"].toBool(false))
				podName = "from-script"

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
			it.fancordionRunner	= this
			it.fixtureInstance	= fixtureInstance
			it.skin				= gimmeSomeSkin()
			it.errs				= Err[,]
			it.stash			= Str:Obj[:] { it.caseInsensitive = true }
		}
		
		try {
			ThreadStack.push("afFancordion.runner", this)
			ThreadStack.push("afFancordion.fixtureMeta", fixMeta)
			ThreadStack.push("afFancordion.fixtureCtx", fixCtx)
					
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
			ThreadStack.pop("afFancordion.runner")
			ThreadStack.pop("afFancordion.fixtureMeta")
			ThreadStack.pop("afFancordion.fixtureCtx")
			
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
			outputDir.create
			// it's better to delete the contents than the actual folder
			// some programs count on the folder always existing
			outputDir.list.each { it.delete }

		} catch (Err err) {
			// sometimes the files are locked...
			msg := "\n"
			msg += "*******************************************************************************\n"
			msg += "** ${err.msg}\n"
			msg += "*******************************************************************************\n"
			msg += "\n"
			log.warn(msg)
		}
	}

	** Called after the last fixture has run.
	** 
	** Writes an 'index.html' file that redirects to the first Fixture run.
	** 
	** Logs the final report.
	virtual Void suiteTearDown(Type:FixtureResult resultsCache) {
		indexFile := outputDir + `index.html`
		if (!indexFile.exists && !resultsCache.isEmpty) {
			url := resultsCache.vals.last.resultFile.uri.relTo(outputDir.uri)
			indexFile.out.print("""<html><head><meta http-equiv="refresh" content="0; url=${url.encode.toXml}" /></head></html>""").close
		}
				
		log.info(finalReport(resultsCache))
	}

	** Creates a pretty report to be printed after the last fixture has been run. 
	virtual Str finalReport(Type:FixtureResult resultsCache) {
		report 		 := "\n\n"
		noOfFailures := resultsCache.reduce(0) |Int failures, result| { failures += result.errors.isEmpty ? 0 : 1 }
		
		if (noOfFailures > 0) {
			report += "Failed:\n"
			maxPad := resultsCache.reduce(0) |Int pad, result| { pad.max(result.errors.size > 0 ? result.fixtureMeta.fixtureType.qname.size : 0) } as Int
			resultsCache.each |result| {
				if (result.errors.size > 0) {
					report += "  " + result.fixtureMeta.fixtureType.qname.plus(" ").padr(maxPad+3, '.') + ". " + result.resultFile.normalize.osPath + "\n"
				}
			}			
			report += "\n"
		}
		
		result := noOfFailures == 0 ? "All Fixtures Passed!" : "$noOfFailures Fixtures FAILED"
		report += "***\n"
		report += "*** ${result} [${resultsCache.size} Fixtures]\n"
		report += "***\n"
		return report
	}
	
	** Called before every fixture.
	** 
	** By default does nothing. 
	virtual Void fixtureSetup(Obj fixtureInstance) { }

	** Called after every fixture.
	** 
	** By default prints the location of the result file. 
	virtual Void fixtureTearDown(Obj fixtureInstance, FixtureResult result) {
		pf := result.errors.isEmpty ? " ... Ok" : " ... FAILED!"
		log.info(result.resultFile.normalize.osPath + pf)
	}
	
	** Rendered when a Fixture fails for an unknown reason - usually due to an error in the skin.
	** 
	** By default this just renders the stack trace.
	virtual Str errorPage(FixtureMeta fixMeta, Err err) { 
"""<!DOCTYPE html>
   <html xmlns="http://www.w3.org/1999/xhtml">
   <head>
   	<title>${fixMeta.title.toXml} : Fancordion</title>
   </head>
   <body>
   <pre>
   ${err.traceToStr}
   </pre>
   </body>
   </html>
   """
	}
	
	** Returns the current 'FancordionRunner' in use, or 'null' if no tests are running. 
	static FancordionRunner? current() {
		ThreadStack.peek("afFancordion.runner", false)
	}
	
	private Str renderFixture(Doc doc, FixtureCtx fixCtx) {
		cmds := Commands(commands)
		fdw	 := FixtureDocWriter(cmds, sectionFuncs, fixCtx)
		fixCtx.skin.setup
		try {
			fdw.docStart(doc)
			doc.writeChildren(fdw)
			fdw.docEnd(doc)
		} finally
			fixCtx.skin.tearDown
		return fixCtx.skin.renderBuf.toStr
	}
}
