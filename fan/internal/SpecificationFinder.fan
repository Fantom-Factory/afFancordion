using compiler

internal const class SpecificationFinder {
	
	// TODO: contribute mixins to make this configurable
	SpecificationMeta findSpecification(Type fixtureType) {
		
		// TODO: find Fandoc via uri in facet
		
		src := findFromTypeFandoc(fixtureType)
		if (src != null)
			return src

		src = findFromSrcFile(fixtureType)
		if (src != null)
			return src

		src = findFromPodFile(fixtureType)
		if (src != null)
			return src
		
		throw Err("Could not find fandoc for Type ${fixtureType.qname}")	// TODO: move err msg
	}

	SpecificationMeta? findFromTypeFandoc(Type fixtureType) {
		try  {
			// TODO: Winge at Fantom - prints an Err if not in a pod
			// assume if we're running a src file then it's not a pod resource
			if (Env.cur.args.last.trim.endsWith(".fan"))
				return null

			if (fixtureType.doc == null)
				return null
		} catch
			return null

		return SpecificationMeta() {
			it.fixtureType		= fixtureType
			it.specificationSrc	= fixtureType.doc
			it.specificationLoc	= `fan://${fixtureType.pod}/${fixtureType.name}.fan`
		}
	}

	SpecificationMeta? findFromSrcFile(Type fixtureType) {
		fileName := fixtureType.name + ".fan"
		srcFile := (File?) null
		baseDir	:= File(`./`).normalize 
		baseDir.walk |file| { if (file.name.equalsIgnoreCase(fileName)) srcFile = file }
		srcStr	:= srcFile?.readAllStr(true)
		return (srcStr == null) ? null : SpecificationMeta {
			it.fixtureType		= fixtureType
			it.specificationSrc	= fandocFromFile(srcStr)
			it.specificationLoc	= srcFile.normalize.uri
		}
	}
	
	SpecificationMeta? findFromPodFile(Type fixtureType) {
		podFile := Env.cur.findPodFile(fixtureType.pod.name)
		if (podFile == null)
			return null
		podZip	:= Zip.open(podFile)
		srcFile	:= podZip.contents.find |file, uri| { uri.path.last == "${fixtureType.name}.fan" }
		srcStr	:= srcFile?.readAllStr(true)
		podZip.close
		
		return (srcStr == null) ? null : SpecificationMeta {
			it.fixtureType		= fixtureType
			it.specificationSrc	= fandocFromFile(srcStr)
			it.specificationLoc	= `fan://${fixtureType.pod}/${fixtureType.name}.fan`
		}
	}

	private Str fandocFromFile(Str srcStr) {
		tokens	:= Tokenizer(Compiler(CompilerInput()), Loc("wotever"), srcStr, true).tokenize
		docCom	:= tokens.find { it.kind == Token.docComment }		
		fandoc	:= ((Str[]) docCom.val).join("\n")
		return fandoc
	}
}

internal const class SpecificationMeta {
	const Type	fixtureType
	const Str	specificationSrc
	const Uri	specificationLoc
	
	new make(|This| in) { in(this) }
}
