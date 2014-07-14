using fandoc
using afBeanUtils
using afPlastic
using concurrent

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
		// we want the fixture _instance_ for if it is a test, the setup has already been done...@~£%]&? 
		// TODO: Need use case for needing to -> simple, we verify and test against stuff in setup()!  
		// Oh, and verify cmd uses it to notch up the verify count 
		if (!fixtureInstance.typeof.hasFacet(Fixture#))
			throw ArgErr(ErrMsgs.fixtureFacetNotFound(fixtureInstance.typeof))		

		if (!Actor.locals.containsKey("afConcordion.runner")) {
			setup()
			Actor.locals["afConcordion.runner"] = this
		}

		startTime	:= DateTime.now(null)
		specMeta	:= SpecificationFinder().findSpecification(fixtureInstance.typeof)
		
		doc			:= FandocParser().parseStr(specMeta.specificationSrc)
		docTitle	:= doc.findHeadings.first?.title ?: specMeta.fixtureType.name.fromDisplayName

		
		
		if (specMeta.specificationLoc.parent.name == "test")
			baseDir = baseDir + `test/`
		if (specMeta.specificationLoc.parent.name == "spec")
			baseDir = baseDir + `spec/`
		
//		fixBuilder	:= BeanFactory(specMeta.fixtureType)
//		fixBuilder.set(FixtureHelper#_concordion_skin, skin)
//		fixBuilder.set(FixtureHelper#_concordion_fixture, fixtureInstance)
//		fixHelper	:= (FixtureHelper) fixBuilder.create

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


		
		Actor.locals["afConcordion.fixtureMeta"]	= fixMeta
		Actor.locals["afConcordion.fixtureCtx"]		= fixCtx
		try {
			
			// TODO: have a fixture setup / teardown
			
			resultHtml	:= renderFixture(doc, fixCtx)	// --> RUN THE TEST!!!
			
			// TODO: maintain dir structure of output files
			resultFile	:= outputDir + `${fixtureInstance.typeof.name}.html` 
			wtf 		:= resultFile.out.print(resultHtml).close
			
			// TODO: print something better
			log.info(resultFile.normalize.toStr)
			
			return FixtureResult {
				it.fixtureMeta	= fixMeta
				it.resultHtml	= resultHtml
				it.resultFile 	= resultFile
				it.errors		= fixCtx.errs
			}
			
		} finally {
			Actor.locals.remove("afConcordion.fixtureMeta")
			Actor.locals.remove("afConcordion.fixtureCtx")
			
			// FIXME: have a suite teardown
		}
		
		return FixtureResult()
	}
	
	** Called when the first fixture is run. 
	virtual Void setup() {
		// wipe the slate clean to begin with
		outputDir.delete
		outputDir.create
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
