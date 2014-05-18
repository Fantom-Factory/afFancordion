using concurrent
using compiler
using afEfan
using afPlastic

class ConcordionRunner {

	ConcordionResults runTest(Type testType, File? f4Fudge := null) {
		efanMeta 	:= generateEfan(testType, f4Fudge)
		testHelper	:= (ConcordionTestHelper) efanMeta.type.make	// TODO: hook for IoC autobuild?

		testHelper._concordion_setUp
		try {
			testHelper->_efan_render(null)
	
			goal := testHelper._concordion_renderBuf.toStr
			
			Env.cur.err.printLine("[$goal]")
	
			resultFile := `build/concordion/${testType.name}.html`.toFile 
			wtf := resultFile.out.print(goal).close
			
			return ConcordionResults {
				it.resultFile 	= resultFile
				it.errors		= testHelper._concordion_errors
			}
			
		} finally {
			testHelper._concordion_tearDown
		}
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
		
		
		efanStr := FandocToEfanConverter().convert(fandoc)
		
		model := PlasticClassModel("${testType.name}Concordion", testType.isConst).extend(testType).extend(ConcordionTestHelper#)
		
		efanEngine	:= EfanEngine(PlasticCompiler())
		classModel	:= efanEngine.parseTemplateIntoModel(testType.qname.toUri, efanStr, model)
		efanOutput	:= classModel.fields.find { it.name == "_efan_output" }
		classModel.fields.remove(efanOutput)
		classModel.addField(Obj?#, "_efan_output", """throw Err("_efan_output is write only.")""", """((StrBuf) concurrent::Actor.locals["afConcordion.renderBuf"]).add(it)""")
		
		efanMeta := efanEngine.compileModel(testType.qname.toUri, efanStr, model)
		
		return ConcordionEfanMeta {
			it.type			= efanMeta.type
			it.typeSrc 		= efanMeta.typeSrc
			it.templateLoc	= efanMeta.templateLoc
			it.templateSrc	= efanMeta.templateSrc
		}
	}
}
