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
		fandocSrc	:= FandocFinder().findFandoc(fixtureInstance.typeof)
		efanMeta 	:= FixtureCompiler().generateEfan(fandocSrc, commands)
		
		if (efanMeta.templateLoc.parent.name == "test")
			baseDir = baseDir + `test/`
		if (efanMeta.templateLoc.parent.name == "spec")
			baseDir = baseDir + `spec/`
		
		fixBuilder	:= BeanFactory(efanMeta.type)
		fixBuilder.set(FixtureHelper#_concordion_skin, skin)
		fixBuilder.set(FixtureHelper#_concordion_fixture, fixtureInstance)
		fixHelper	:= (FixtureHelper) fixBuilder.create

		// TODO: maintain dir structure of output files
		resultFile	:= outputDir + `${fixtureInstance.typeof.name}.html` 

		fixMeta		:= FixtureMeta() {
			it.title		= efanMeta.title 
			it.fixtureType	= efanMeta.type
			it.fixtureSrc	= efanMeta.typeSrc
			it.templateLoc	= efanMeta.templateLoc
			it.templateSrc	= efanMeta.templateSrc
			it.baseDir		= this.baseDir
			it.outputDir	= this.outputDir
			it.resultFile	= resultFile
			it.StartTime	= startTime
		}
		
		fixHelper._concordion_setUp(fixMeta)
		try {
			fixHelper	-> _efan_render(null)	// --> RUNS THE TEST!!!
			resultHtml	:= fixHelper._concordion_renderBuf.toStr
			wtf 		:= resultFile.out.print(resultHtml).close
			
			// TODO: print something better
			log.info(resultFile.normalize.toStr)
			
			return FixtureResult {
				it.fixtureMeta	= fixMeta
				it.resultHtml	= resultHtml
				it.resultFile 	= resultFile
				it.errors		= fixHelper._concordion_errors
			}
			
		} finally {
			fixHelper._concordion_tearDown
			
			// FIXME: have a suite teardown
		}
	}
	
	** Called when the first fixture is run. 
	virtual Void setup() {
		// wipe the slate clean to begin with
		outputDir.delete
		outputDir.create
		
		
	}
}
