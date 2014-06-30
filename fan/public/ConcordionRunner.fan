using fandoc
using afBeanUtils
using afEfan
using afPlastic

class ConcordionRunner {
	private static const Log log	:= Utils.getLog(ConcordionRunner#)
	
	File			outputDir		:= Env.cur.tempDir + `concordion/`
	ConcordionSkin	skin			:= ConcordionSkinImpl()
	Str:Command		commands		:= Str:Command[:] { caseInsensitive = true }
	
	@NoDoc
	new make() {
		commands["verify"]	= CmdVerify()
//		commands["execute"]	= CmdExecute()
//		commands["set"]		= CmdSet()
//		commands["file"]	= CmdLink()
//		commands["http"]	= CmdLink()
//		commands["https"]	= CmdLink()
	}
	
	ConcordionResults runTest(Type testType) {
		testStart	:= Duration.now
		fandocSrc	:= FandocFinder().findFandoc(testType)
		efanMeta 	:= TestCompiler().generateEfan(fandocSrc, commands)
		
		// TODO: hook for IoC autobuild?
		testBuilder	:= BeanFactory(efanMeta.type).set(TestHelper#_concordion_skin, skin)
		testHelper	:= (TestHelper) testBuilder.create	

		testHelper._concordion_setUp
		try {
			testTime	:= Duration.now - testStart
			testHelper	-> _efan_render(null)	// --> RUNS THE TEST!!!
			goal 		:= testHelper._concordion_renderBuf.toStr
			result 		:= render(goal, efanMeta.title, testTime)
			resultFile	:= outputDir + `${testType.name}.html` 
			wtf 		:= resultFile.out.print(result).close
			
			// TODO: print something better
			log.info(resultFile.normalize.toStr)
			
			return ConcordionResults {
				it.result 		= result
				it.resultFile 	= resultFile
				it.errors		= testHelper._concordion_errors
			}
			
		} finally {
			testHelper._concordion_tearDown
		}
	}
	
	private Str render(Str content, Str title, Duration testDuration) {
		// TODO: we could make this part of the efan template
		conCss		:= typeof.pod.file(`/res/concordion.css`		).readAllStr
		visToggler	:= typeof.pod.file(`/res/visibility-toggler.js`	).readAllStr
		conXhtml	:= typeof.pod.file(`/res/concordion.html`		).readAllStr
		conVersion	:= typeof.pod.version.toStr
		xhtml		:= conXhtml 
						.replace("{{{ title }}}", 				title)
						.replace("{{{ concordionCss }}}", 		conCss)
						.replace("{{{ visibilityToggler }}}", 	visToggler)
						.replace("{{{ content }}}", 			content)
						.replace("{{{ concordionVersion }}}",	conVersion)
						.replace("{{{ testDuration }}}", 		testDuration.toLocale)
						.replace("{{{ testDate }}}", 			DateTime.now(1sec).toLocale("D MMM YYYY, k:mmaa zzzz 'Time'"))
		return xhtml
	}
}
