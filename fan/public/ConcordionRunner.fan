using fandoc
using afEfan
using afPlastic

class ConcordionRunner {
	private static const Log log	:= Utils.getLog(ConcordionRunner#)
	
	File? outputDir
	
	new make() {
		outputDir = File(`./`)
	}
	
	ConcordionResults runTest(Type testType) {
		fandocSrc	:= FandocFinder().findFandoc(testType)
		efanMeta 	:= TestCompiler().generateEfan(fandocSrc)
		testHelper	:= (TestHelper) efanMeta.type.make	// TODO: hook for IoC autobuild?

		testHelper._concordion_setUp
		try {
			testHelper->_efan_render(null)
	
			goal 		:= testHelper._concordion_renderBuf.toStr
			result 		:= render(goal, efanMeta.title)
			resultFile	:= outputDir + `build/concordion/${testType.name}.html` 
			wtf 		:= resultFile.out.print(result).close
			
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
	
	private Str render(Str content, Str title) {
		conCss		:= typeof.pod.file(`/res/concordion.css`).readAllStr
		conXhtml	:= typeof.pod.file(`/res/concordion.html`).readAllStr
		conVersion	:= typeof.pod.version.toStr
		xhtml		:= conXhtml 
						.replace("{{{ title }}}", title)
						.replace("{{{ concordionCss }}}", conCss)
						.replace("{{{ content }}}", content)
						.replace("{{{ concordionVersion }}}", conVersion)
		return xhtml
	}
}
