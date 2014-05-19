using fandoc
using compiler
using afEfan
using afPlastic

class ConcordionRunner {
	private static const Log log	:= Utils.getLog(ConcordionRunner#)
	
	ConcordionResults runTest(Type testType, File? f4Fudge := null) {
		efanMeta 	:= generateEfan(testType, f4Fudge)
		testHelper	:= (ConcordionTestHelper) efanMeta.type.make	// TODO: hook for IoC autobuild?

		testHelper._concordion_setUp
		try {
			testHelper->_efan_render(null)
	
			goal 		:= testHelper._concordion_renderBuf.toStr
			result 		:= render(goal, efanMeta.title)
			resultFile	:= (f4Fudge.parent + `../build/concordion/${testType.name}.html`) 
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
	
	private ConcordionEfanMeta generateEfan(Type testType, File? f4Fudge := null) {
		// fandoc	:= testType.doc
		// TODO: if doc is null, then look for a file

		srcFromPod := |->Str| {
			podFile := Env.cur.findPodFile(testType.pod.name)
			podZip	:= Zip.open(podFile)
			srcFile	:= podZip.contents.find |file, uri| { uri.path.last == "${testType.name}.fan" } ?: throw Err("Src file not found: ${podZip.contents.keys}")
			srcStr	:= srcFile.readAllStr(true)
			podZip.close
			return srcStr
		}
		
		srcStr := (f4Fudge == null) ? srcFromPod() : f4Fudge.readAllStr

		tokens	:= Tokenizer(Compiler(CompilerInput()), Loc("wotever"), srcStr, true).tokenize
		docCom	:= tokens.find { it.kind == Token.docComment }		
		fandoc	:= ((Str[]) docCom.val).join("\n")
		
		doc		:= FandocParser().parseStr(fandoc)
		efanStr	:= printDoc(doc.children).replace("&lt;%", "<%")
		docTitle:= doc.findHeadings.first?.title ?: testType.name.fromDisplayName
		
		model := PlasticClassModel("${testType.name}Concordion", testType.isConst).extend(testType).extend(ConcordionTestHelper#)
		
		efanEngine	:= EfanEngine(PlasticCompiler())
		classModel	:= efanEngine.parseTemplateIntoModel(testType.qname.toUri, efanStr, model)
		efanOutput	:= classModel.fields.find { it.name == "_efan_output" }
		classModel.fields.remove(efanOutput)
		classModel.addField(Obj?#, "_efan_output", """throw Err("_efan_output is write only.")""", """((StrBuf) concurrent::Actor.locals["afConcordion.renderBuf"]).add(it)""")
		
		efanMeta := efanEngine.compileModel(testType.qname.toUri, efanStr, model)
		
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
