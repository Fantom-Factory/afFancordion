using fandoc
using afBeanUtils
using afPlastic

** Runs Concordion fixtures.
class ConcordionRunner {
	private static const Log log	:= Utils.getLog(ConcordionRunner#)
	
	** Where the tests are run from. 
	** Used to work out relative paths from test files to resource directories.
	File			baseDir			:= File.make(`./`)
	
	** Where the generated HTML result files are saved.
	File			outputDir		:= Env.cur.tempDir + `concordion/`
	
	** The skin applied to generated HTML result files.
	ConcordionSkin	skin			:= ConcordionSkinImpl()
	
	** The commands made available to Concordion tests. 
	Str:Command		commands		:= Str:Command[:] { caseInsensitive = true }
	
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
		
		// TODO: work out what baseDir should be if running tests from a pod
	}

	** Runs the given Concordion fixture.
	FixtureResult runFixture(Obj fixtureInstance) {
		// we need the fixture *instance* so it can have any state, 
		// and if a Test instance, verify cmd uses it to notch up the verify count

		if (!fixtureInstance.typeof.hasFacet(Fixture#))
			throw ArgErr(ErrMsgs.fixtureFacetNotFound(fixtureInstance.typeof))		

		firstFixture := false
		if (ThreadStack.peek("afConcordion.runner", false) == null) {
			firstFixture = true
			suiteSetup()
		}

		startTime	:= DateTime.now(null)
		specMeta	:= SpecificationFinder().findSpecification(fixtureInstance.typeof)
		doc			:= FandocParser().parseStr(specMeta.specificationSrc)
		docTitle	:= doc.findHeadings.first?.title ?: specMeta.fixtureType.name.fromDisplayName
		
		if (specMeta.specificationLoc.parent.name == "test")
			baseDir = baseDir + `test/`
		if (specMeta.specificationLoc.parent.name == "spec")
			baseDir = baseDir + `spec/`
		
		fixMeta		:= FixtureMeta() {
			it.title			= docTitle
			it.fixtureType		= specMeta.fixtureType
			it.specificationLoc	= specMeta.specificationLoc
			it.specificationSrc	= specMeta.specificationSrc
			it.baseDir			= this.baseDir
			it.outputDir		= this.outputDir
			it.StartTime		= startTime
		}
		
		fixCtx		:= FixtureCtx() {
			it.fixtureInstance	= fixtureInstance
			it.skin				= this.skin
			it.renderBuf		= StrBuf(specMeta.specificationSrc.size * 2)
			it.errs				= Err[,]
		}
		
		try {
			ThreadStack.push("afConcordion.runner", this)
			ThreadStack.push("afConcordion.fixtureMeta", fixMeta)
			ThreadStack.push("afConcordion.fixtureCtx", fixCtx)
					
			fixtureSetup()
			
			resultHtml	:= renderFixture(doc, fixCtx)	// --> RUN THE TEST!!!
			
			resultFile	:= outputDir + `${fixtureInstance.typeof.name}.html` 
			resultFile.out.print(resultHtml).close
						
			result := FixtureResult {
				it.fixtureMeta	= fixMeta
				it.resultHtml	= resultHtml
				it.resultFile 	= resultFile
				it.errors		= fixCtx.errs
			}
			
			fixtureTearDown(result)

			return result
			
		} finally {
			if (firstFixture)
				suiteTearDown()

			ThreadStack.pop("afConcordion.runner")
			ThreadStack.pop("afConcordion.fixtureMeta")
			ThreadStack.pop("afConcordion.fixtureCtx")
		}
	}
	
	** Called before the first fixture is run.
	** 
	** By default this empties the output dir. 
	virtual Void suiteSetup() {
		// FIXME: with multiple tests in fant - this gets run every time!
		// wipe the slate clean to begin with
		outputDir.delete
		outputDir.create
		
		Env.cur.err.printLine("Suite Setup!")
	}

	** Called after the last fixture has run.
	** 
	** By default does nothing. 
	virtual Void suiteTearDown() { }

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
	
	private Str renderFixture(Doc doc, FixtureCtx fixCtx) {
		cmds := Commands(commands)
		fdw	 := FixtureDocWriter(cmds, fixCtx)
		fdw.docStart(doc)
		doc.writeChildren(fdw)
		fdw.docEnd(doc)
		return fixCtx.renderBuf.toStr			
	}
}
