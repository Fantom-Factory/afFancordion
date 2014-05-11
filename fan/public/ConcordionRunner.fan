using afIoc
using afEfan
using afPlastic
using compiler

class ConcordionRunner {

//	@Inject	private ConcordionTests concordionTests
//	
//	new make(|This|in) { in(this) }
//	
//	Void runTests() {
//		concordionTests.findTests.each |conTestType| { 
//			efanXtra.component(conTestType).renderTemplate
//		}
//	}
//	
//	
//	static Void main(Str[] args) {
//		reg := RegistryBuilder().addModule(ConcordionModule#).build.startup
//		
//		runner := (ConcordionRunner) reg.dependencyByType(ConcordionRunner#)
//		
//		reg.shutdown
//	}
	
//	Void main() {
//		runTest(VerifyEqTest#)
//	}

	Void runTest(Type testType, File? f4Fudge := null) {
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
		
//		fandoc	:= testType.doc
		
		Env.cur.err.printLine(fandoc)
		
		// TODO: if doc is null, look for a file
		
		efanStr := FandocToEfanConverter().convert(fandoc)
		
		model := PlasticClassModel("ConTest", testType.isConst).extendClass(testType)
		
		efanMetaData := EfanCompiler().compileWithModel(testType.qname.toUri, efanStr, null, model)
		test := CtorPlanBuilder(efanMetaData.efanType).set("efanMetaData", efanMetaData).makeObj
		renderBuf := StrBuf()
		EfanRenderCtx.renderEfan(renderBuf, test, null) |->| {
			test->_af_render(null)
		}
		goal := renderBuf.toStr
		
		
		Env.cur.err.printLine("[$goal]")
		
	}
}

internal class CtorPlanBuilder {
	private Type 		type
	private Field:Obj? 	ctorPlan := [:]
	
	new make(Type type) {
		this.type = type
	}
	
	** Fantom Bug: http://fantom.org/sidewalk/topic/2163#c13978
	@Operator 
	private Obj? get(Obj key) { null }

	@Operator
	This set(Str fieldName, Obj? val) {
		field := type.field(fieldName)
		ctorPlan[field] = val
		return this
	}

	|Obj| toCtorFunc() {
		Field.makeSetFunc(ctorPlan)
	}

	Obj makeObj() {
		type.make([toCtorFunc])
	}
}