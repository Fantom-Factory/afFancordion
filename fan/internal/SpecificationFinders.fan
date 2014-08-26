using compiler

internal class SpecificationFinders {
	
	private SpecificationFinder[] finders
	
	new make(SpecificationFinder[] finders) {
		this.finders = finders
	}
	
	SpecificationMeta findSpecification(Type fixtureType) {
		finders.eachWhile { it.findSpecification(fixtureType) }
			?: throw Err(ErrMsgs.specFinder_couldNotFindSpec(fixtureType))
	}
}

internal class FindSpecFromFacetValue : SpecificationFinder {
	
	override SpecificationMeta? findSpecification(Type fixtureType) {
		
		fixFacet := (Fixture) Type#.method("facet").callOn(fixtureType, [Fixture#])	// Stoopid F4
		specFile := findFile(fixtureType, fixFacet.specification)
		return specFile == null ? null : SpecificationMeta() {
			it.fixtureType		= fixtureType
			it.specificationSrc	= specFile.readAllStr
			it.specificationLoc	= fixFacet.specification
		}
	}
	
	static File? findFile(Type fixtureType, Uri? specUrl) {
		if (specUrl == null)
			return null
		
		if (specUrl.isDir)
			specUrl = specUrl.plusName("${fixtureType.name}.fandoc")
		
		
		// if absolute, it should resolve against a scheme (hopefully fan:!)
		if (specUrl.isAbs) {
			obj := specUrl.get
			if (!obj.typeof.fits(File#))
				throw Err(ErrMsgs.specFinder_specNotFile(specUrl, fixtureType, obj.typeof))
			return obj
		}
		
		// if relative, a local file maybe?
		efanFile := specUrl.toFile 
		if (efanFile.exists)
			return efanFile
		
		// last ditch attempt, look for a local pod resource
		if (specUrl.isPathAbs)
			specUrl = specUrl.toStr[1..-1].toUri
		obj := `fan://${fixtureType.pod}/${specUrl}`.get(null, false)
		if (obj == null)
			throw Err(ErrMsgs.specFinder_specNotFound(specUrl, fixtureType))
		if (!obj.typeof.fits(File#))
			throw Err(ErrMsgs.specFinder_specNotFile(specUrl, fixtureType, obj.typeof))
		return obj		
	}
}

internal class FindSpecFromTypeFandoc : SpecificationFinder {

	override SpecificationMeta? findSpecification(Type fixtureType) {
		try  {
			// TODO: Winge at Fantom - prints an Err if not in a pod
			// see 'fan.sys.ClassType.java'
			// see http://fantom.org/sidewalk/topic/2335
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
}

internal class FindSpecFromSrcFile : SpecificationFinder {
	
	override SpecificationMeta? findSpecification(Type fixtureType) {
		fileName := fixtureType.name + ".fan"
		srcFile := (File?) null
		baseDir	:= File(`./`).normalize 
		baseDir.walk |file| { if (file.name.equalsIgnoreCase(fileName)) srcFile = file }
		srcStr	:= srcFile?.readAllStr(true)
		return (srcStr == null) ? null : SpecificationMeta {
			it.fixtureType		= fixtureType
			it.specificationSrc	= fandocFromTypeSrc(srcStr)
			it.specificationLoc	= srcFile.normalize.uri
		}
	}

	private Str fandocFromTypeSrc(Str srcStr) {
		tokens	:= Tokenizer(Compiler(CompilerInput()), Loc("wotever"), srcStr, true).tokenize
		docCom	:= tokens.find { it.kind == Token.docComment }		
		fandoc	:= ((Str[]) docCom.val).join("\n")
		return fandoc
	}
}
	
internal class FindSpecFromPodFile : SpecificationFinder {

	override SpecificationMeta? findSpecification(Type fixtureType) {
		podFile := Env.cur.findPodFile(fixtureType.pod.name)
		if (podFile == null)
			return null
		podZip	:= Zip.open(podFile)
		srcFile	:= podZip.contents.find |file, uri| { uri.path.last == "${fixtureType.name}.fan" }
		srcStr	:= srcFile?.readAllStr(true)
		podZip.close
		
		return (srcStr == null) ? null : SpecificationMeta {
			it.fixtureType		= fixtureType
			it.specificationSrc	= fandocFromTypeSrc(srcStr)
			it.specificationLoc	= `fan://${fixtureType.pod}/${fixtureType.name}.fan`
		}
	}

	private Str fandocFromTypeSrc(Str srcStr) {
		tokens	:= Tokenizer(Compiler(CompilerInput()), Loc("wotever"), srcStr, true).tokenize
		docCom	:= tokens.find { it.kind == Token.docComment }		
		fandoc	:= ((Str[]) docCom.val).join("\n")
		return fandoc
	}
}
