using compiler

internal const class FandocFinder {
	
	FandocSrc findFandoc(Type testType) {
		
		src := findFromTypeFandoc(testType)
		if (src != null)
			return src

		src = findFromSrcFile(testType)
		if (src != null)
			return src

		src = findFromPodFile(testType)
		if (src != null)
			return src
		
		throw Err("Could not find fandoc for Type ${testType.qname}")	// TODO: move err msg
	}

	FandocSrc? findFromTypeFandoc(Type testType) {
		if (testType.doc == null)
			return null
		
		return FandocSrc() {
			it.type			= testType
			it.fandoc		= testType.doc
			it.templateLoc	= `fan://${testType.pod}/${testType.name}.fan`
		}
	}

	FandocSrc? findFromSrcFile(Type testType) {
		fileName := testType.name + ".fan"
		srcFile := (File?) null
		File(`./`).walk |file| { if (file.name.equalsIgnoreCase(fileName)) srcFile = file }
		srcStr	:= srcFile?.readAllStr(true)
		
		return (srcStr == null) ? null : FandocSrc {
			it.type			= testType
			it.fandoc		= fandocFromFile(srcStr)
			it.templateLoc	= srcFile.normalize.uri
		}
	}
	
	FandocSrc? findFromPodFile(Type testType) {
		podFile := Env.cur.findPodFile(testType.pod.name)
		podZip	:= Zip.open(podFile)
		srcFile	:= podZip.contents.find |file, uri| { uri.path.last == "${testType.name}.fan" }
		srcStr	:= srcFile?.readAllStr(true)
		podZip.close
		
		return (srcStr == null) ? null : FandocSrc {
			it.type			= testType
			it.fandoc		= fandocFromFile(srcStr)
			it.templateLoc	= `fan://${testType.pod}/${testType.name}.fan`
		}
	}

	private Str fandocFromFile(Str srcStr) {
		tokens	:= Tokenizer(Compiler(CompilerInput()), Loc("wotever"), srcStr, true).tokenize
		docCom	:= tokens.find { it.kind == Token.docComment }		
		fandoc	:= ((Str[]) docCom.val).join("\n")
		return fandoc
	}
}

internal const class FandocSrc {
	const Type	type
	const Str	fandoc
	const Uri	templateLoc
	
	new make(|This| in) { in(this) }
}
