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
		efanMeta 	:= generateEfan(fandocSrc)
		testHelper	:= (ConcordionTestHelper) efanMeta.type.make	// TODO: hook for IoC autobuild?

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
	
	private ConcordionEfanMeta generateEfan(FandocSrc fandocSrc) {		
		doc		:= FandocParser().parseStr(fandocSrc.fandoc)
		efanStr	:= printDoc(doc.children).replace("&lt;%", "<%")
		docTitle:= doc.findHeadings.first?.title ?: fandocSrc.type.name.fromDisplayName
		
		model := PlasticClassModel("${fandocSrc.type.name}Concordion", fandocSrc.type.isConst).extend(fandocSrc.type).extend(ConcordionTestHelper#)
		
		efanEngine	:= EfanEngine(PlasticCompiler())
		classModel	:= efanEngine.parseTemplateIntoModel(fandocSrc.templateLoc, efanStr, model)
		efanOutput	:= classModel.fields.find { it.name == "_efan_output" }
		classModel.fields.remove(efanOutput)
		classModel.addField(Obj?#, "_efan_output", """throw Err("_efan_output is write only.")""", """((StrBuf) concurrent::Actor.locals["afConcordion.renderBuf"]).add(it)""")
		
		efanMeta := efanEngine.compileModel(fandocSrc.templateLoc, efanStr, model)
		
		return ConcordionEfanMeta {
			it.title		= docTitle
			it.type			= efanMeta.type
			it.typeSrc 		= efanMeta.typeSrc
			it.templateLoc	= efanMeta.templateLoc
			it.templateSrc	= efanMeta.templateSrc
		}
	}
	

	private Str printDoc(DocElem[] doc) {
		buf	:= StrBuf()
		cmds := ConcordionCommands(buf.out)
		dw	:= ConcordionDocWriter(buf.out, cmds)
		doc.each { it.write(dw) }
		return buf.toStr			
	}
}
