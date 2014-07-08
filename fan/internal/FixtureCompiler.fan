using fandoc
using afEfan
using afPlastic

internal const class FixtureCompiler {

	private const EfanEngine 	efanEngine	:= EfanEngine(PlasticCompiler())
	
	EfanMeta generateEfan(FandocSrc fandocSrc, Str:Command commands) {
		doc		:= FandocParser().parseStr(fandocSrc.fandoc)
		efanStr	:= renderFandoc(doc, commands).replace("&lt;%", "<%")
		docTitle:= doc.findHeadings.first?.title ?: fandocSrc.type.name.fromDisplayName
		
		model	:= PlasticClassModel("${fandocSrc.type.name}Concordion", fandocSrc.type.isConst).extend(fandocSrc.type).extend(FixtureHelper#)
		
		classModel	:= efanEngine.parseTemplateIntoModel(fandocSrc.templateLoc, efanStr, model)
		efanOutput	:= classModel.fields.find { it.name == "_efan_output" }
		classModel.fields.remove(efanOutput)
		classModel.addField(Obj?#, "_efan_output", """throw Err("_efan_output is write only.")""", """_concordion_renderBuf.add(it)""")
		classModel.overrideField(FixtureHelper#_concordion_skin)
		classModel.overrideField(FixtureHelper#_concordion_testInstance)
		
		efanMeta := efanEngine.compileModel(fandocSrc.templateLoc, efanStr, model)

		return EfanMeta {
			it.title		= docTitle
			it.type			= efanMeta.type
			it.typeSrc 		= efanMeta.typeSrc
			it.templateLoc	= efanMeta.templateLoc
			it.templateSrc	= efanMeta.templateSrc
		}
	}
	
	private Str renderFandoc(Doc doc, Str:Command commands) {
		buf	 := StrBuf()
		cmds := Commands(commands, buf.out)
		dw	 := FixtureDocWriter(buf.out, cmds)
		dw.docStart(doc)
		doc.writeChildren(dw)
		dw.docEnd(doc)
		return buf.toStr			
	}
}

internal const class EfanMeta {
	const Str 	title
	const Type	type
	const Str 	typeSrc
	const Uri 	templateLoc
	const Str 	templateSrc
	
	internal new make(|This|? in := null) { in?.call(this) }
}