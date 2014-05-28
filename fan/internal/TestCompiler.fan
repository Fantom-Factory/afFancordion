using fandoc
using afEfan
using afPlastic

internal class TestCompiler {
	
	ConcordionEfanMeta generateEfan(FandocSrc fandocSrc) {		
		doc		:= FandocParser().parseStr(fandocSrc.fandoc)
		efanStr	:= renderFandoc(doc).replace("&lt;%", "<%")
		docTitle:= doc.findHeadings.first?.title ?: fandocSrc.type.name.fromDisplayName
		
		model := PlasticClassModel("${fandocSrc.type.name}Concordion", fandocSrc.type.isConst).extend(fandocSrc.type).extend(TestHelper#)
		
		efanEngine	:= EfanEngine(PlasticCompiler())
		classModel	:= efanEngine.parseTemplateIntoModel(fandocSrc.templateLoc, efanStr, model)
		efanOutput	:= classModel.fields.find { it.name == "_efan_output" }
		classModel.fields.remove(efanOutput)
		classModel.addField(Obj?#, "_efan_output", """throw Err("_efan_output is write only.")""", """_concordion_renderBuf.add(it)""")
		
		efanMeta := efanEngine.compileModel(fandocSrc.templateLoc, efanStr, model)
		
		return ConcordionEfanMeta {
			it.title		= docTitle
			it.type			= efanMeta.type
			it.typeSrc 		= efanMeta.typeSrc
			it.templateLoc	= efanMeta.templateLoc
			it.templateSrc	= efanMeta.templateSrc
		}
	}
	
	private Str renderFandoc(Doc doc) {
		buf	 := StrBuf()
		cmds := ConcordionCommands(buf.out)
		dw	 := ConcordionDocWriter(buf.out, cmds)
		dw.docStart(doc)
		doc.writeChildren(dw)
		dw.docEnd(doc)
		return buf.toStr			
	}
}
