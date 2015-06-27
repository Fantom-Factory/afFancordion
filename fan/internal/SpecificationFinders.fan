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
		
		// if absolute, it should resolve against a scheme (hopefully fan:!)
		if (specUrl.isAbs) {
			if (specUrl.isDir)
				// TODO: should also look for .specification and .spec
				specUrl = specUrl.plusName("${fixtureType.name}.fandoc")
			obj := specUrl.get
			if (!obj.typeof.fits(File#))
				throw Err(ErrMsgs.specFinder_specNotFile(specUrl, fixtureType, obj.typeof))
			return obj
		}
		
		// if relative, a local file maybe?
		specUrls := Uri[,]
		if (specUrl.isDir) {
			specUrls.add(specUrl.plusName("${fixtureType.name}.specification"))
			specUrls.add(specUrl.plusName("${fixtureType.name}.spec"))
			specUrls.add(specUrl.plusName("${fixtureType.name}.fandoc"))			
		} else
			specUrls.add(specUrl)
		file := specUrls.eachWhile { it.toFile.exists ? it.toFile : null }
		if (file != null)
			return file
		
		// last ditch attempt, look for a local pod resource
		if (specUrl.isPathAbs)
			specUrl = specUrl.toStr[1..-1].toUri
		obj := `fan://${fixtureType.pod}/${specUrl}`.get(null, false)
		if (obj != null) {
			if (!obj.typeof.fits(File#))
				throw Err(ErrMsgs.specFinder_specNotFile(specUrl, fixtureType, obj.typeof))
			return obj
		}

		obj = fixtureType.pod.files.find |podFile| {
			podFile.name == specUrl.toStr
		}
		if (obj != null)
			return obj		
		
		throw Err(ErrMsgs.specFinder_specNotFound(specUrl, fixtureType))
	}
}

** Returns the type's fandoc 
internal class FindSpecFromTypeFandoc : SpecificationFinder {

	override SpecificationMeta? findSpecification(Type fixtureType) {
		try  {
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

** Returns the type's fandoc, loaded from the src file on the file system
internal class FindSpecFromTypeInSrcFile : SpecificationFinder {
	
	override SpecificationMeta? findSpecification(Type fixtureType) {
		fileName := fixtureType.name + ".fan"
		srcFile := (File?) null
		baseDir	:= File(`./`).normalize 
		try
			baseDir.walk |file| { 
				if (file.name.equalsIgnoreCase(fileName)) {
					srcFile = file
					throw CancelledErr()	// break out of the file walking
				}
			}
		catch (CancelledErr err) { }
		srcStr	:= fandocFromTypeSrc(srcFile)
		return (srcStr == null) ? null : SpecificationMeta {
			it.fixtureType		= fixtureType
			it.specificationSrc	= srcStr
			it.specificationLoc	= srcFile.normalize.uri
		}
	}

	private Str? fandocFromTypeSrc(File? srcFile) {
		if (srcFile == null)
			return null
		srcStr	:= srcFile.readAllStr(true)
		tokens	:= Tokenizer(Compiler(CompilerInput()), Loc("wotever"), srcStr, true).tokenize
		docCom	:= tokens.find { it.kind == Token.docComment }		
		fandoc	:= ((Str[]?) docCom?.val)?.join("\n")
		return fandoc?.trimToNull
	}
}
	
** Returns the type's fandoc, loaded from a src file in the pod
internal class FindSpecFromTypeInPodFile : SpecificationFinder {

	override SpecificationMeta? findSpecification(Type fixtureType) {
		podFile := Env.cur.findPodFile(fixtureType.pod.name)
		if (podFile == null)
			return null
		podZip	:= Zip.open(podFile)
		srcFile	:= podZip.contents.find |file, uri| { uri.path.last == "${fixtureType.name}.fan" }
		srcStr	:= fandocFromTypeSrc(srcFile)
		podZip.close
		
		return (srcStr == null) ? null : SpecificationMeta {
			it.fixtureType		= fixtureType
			it.specificationSrc	= srcStr
			it.specificationLoc	= `fan://${fixtureType.pod}/${fixtureType.name}.fan`
		}
	}

	private Str? fandocFromTypeSrc(File? srcFile) {
		if (srcFile == null)
			return null
		srcStr	:= srcFile.readAllStr(true)
		tokens	:= Tokenizer(Compiler(CompilerInput()), Loc("wotever"), srcStr, true).tokenize
		docCom	:= tokens.find { it.kind == Token.docComment }		
		fandoc	:= ((Str[]?) docCom?.val)?.join("\n")
		return fandoc?.trimToNull
	}
}

** Returns a spec file from the pod
internal class FindSpecInPodFile : SpecificationFinder {

	override SpecificationMeta? findSpecification(Type fixtureType) {
		podFile := Env.cur.findPodFile(fixtureType.pod.name)
		if (podFile == null)
			return null
		podZip	:= Zip.open(podFile)
		srcFile	:= podZip.contents.find |file, uri| { 
			fileName := uri.path.last 
			if (fileName == "${fixtureType.name}.specification")
				return true
			if (fileName == "${fixtureType.name}.spec")
				return true
			if (fileName == "${fixtureType.name}.fandoc")
				return true	
			return false
		}
		srcStr	:= srcFile?.readAllStr(true)
		podZip.close
		
		return (srcStr == null) ? null : SpecificationMeta {
			it.fixtureType		= fixtureType
			it.specificationSrc	= srcStr
			it.specificationLoc	= `fan://${fixtureType.pod}/${fixtureType.name}.fan`
		}
	}

	private Str? fandocFromTypeSrc(File? srcFile) {
		if (srcFile == null)
			return null
		srcStr	:= srcFile.readAllStr(true)
		tokens	:= Tokenizer(Compiler(CompilerInput()), Loc("wotever"), srcStr, true).tokenize
		docCom	:= tokens.find { it.kind == Token.docComment }		
		fandoc	:= ((Str[]?) docCom?.val)?.join("\n")
		return fandoc?.trimToNull
	}
}

** Returns a spec file from the file system
internal class FindSpecOnFileSystem : SpecificationFinder {
	
	override SpecificationMeta? findSpecification(Type fixtureType) {
		exts 	:= "specification spec fandoc".split
		srcFile := (File?) null
		baseDir	:= File(`./`).normalize
		try
			baseDir.walk |file| {
				exts.each |ext| {
					fileName := fixtureType.name + "." + ext
					if (file.name.equalsIgnoreCase(fileName)) {
						srcFile = file
						throw CancelledErr()	// break out of the file walking
					}
				}
			}
		catch (CancelledErr err) { }
		
		srcStr	:= srcFile?.readAllStr(true)
		return (srcStr == null) ? null : SpecificationMeta {
			it.fixtureType		= fixtureType
			it.specificationSrc	= srcStr
			it.specificationLoc	= srcFile.normalize.uri
		}
	}
}
