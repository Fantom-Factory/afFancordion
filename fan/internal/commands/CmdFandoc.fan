
internal class CmdFandoc : Command {

	override Void runCommand(FixtureCtx fixCtx, CommandCtx cmdCtx) {
		fandocUri := FandocUri(cmdCtx.cmdUri)
		if (fandocUri == null)
			return
		
		html := fixCtx.skin.a(fandocUri.toAbsUrl, cmdCtx.cmdText)
		fixCtx.renderBuf.add(html)
	}
}

internal const class FandocUri {

	private static const Str[] coreDocNames := "docIntro docLang docFanr docTools".split
	private static const Str[] corePodNames := "docIntro docLang docFanr docTools build compiler compilerDoc compilerJava compilerJs concurrent dom email fandoc fanr fansh flux fluxText fwt gfx inet obix sql syntax sys util web webfwt webmod wisp xml".split

	const Str	pod
	const Str?	type
	const Str?	slot
	const Str?	file
	const Str?	frag
	const Int?	line
	const Bool	isSummary
	const Bool	isDoc
	const Bool	isApi
	const Bool	isSrc

	private new makeSummary(Str pod) {
		this.isSummary = true
		this.pod = pod
	}

	private new makeDoc(Str pod, Str file, Str? frag) {
		this.isDoc	= true
		this.pod	= pod
		this.file	= file
		this.frag	= frag
	}

	private new makeApi(Str pod, Str? type, Str? slot) {
		this.isApi	= true
		this.pod	= pod
		this.type	= type
		this.slot	= slot
	}
	
	private new makeSrc(Str pod, Str? type, Int? line) {
		this.isSrc	= true
		this.pod	= pod
		this.type	= type
		this.line	= line
	}
	
	private new static fromFandocUri(Uri uri, Bool checked := true) {
		if (uri.scheme != "fandoc")
			return null ?: (checked ? throw ParseErr("Invalid FandocUri: ${uri}") : null)

		path := uri.path.rw
		if (path.isEmpty)
			return null ?: (checked ? throw ParseErr("Invalid FandocUri: ${uri}") : null)

		pod := path.removeAt(0)
		
		if (path.isEmpty)
			return makeSummary(pod)

		section := path.removeAt(0)
		if (section == "doc") {
			if (path.isEmpty)
				return makeDoc(pod, "pod.fandoc", null)
			
			file := path.join("/")
			if (file.toUri.ext == null)
				file += ".fandoc"
			return makeDoc(pod, file, uri.frag)
		}

		if (section == "api") {
			if (path.isEmpty)
				return makeApi(pod, null, null)
			
			type := path.removeAt(0)
			if (path.isEmpty)
				return makeApi(pod, type, uri.frag)
			
			if (path.size == 1 && path.first == "src")
				return makeSrc(pod, type, uri.frag?.getRange(4..-1)?.toInt)

			return null ?: (checked ? throw ParseErr("Invalid FandocUri: ${uri}") : null)
		}
		
		return null ?: (checked ? throw ParseErr("Invalid FandocUri: ${uri}") : null)
	}

	private new static fromFantomUri(Str str, Bool checked := true) {
		if (!str.contains("::"))
			return null ?: (checked ? throw ParseErr("Invalid FantomUri: ${str}") : null)
		
		if (str.split(':').size > 3)
			return null ?: (checked ? throw ParseErr("Invalid FantomUri: ${str}") : null)

		pod	 := str.split(':').first
		type := str[pod.size+2..-1]

		if (type == "index" || type.isEmpty)
			return makeSummary(pod)

		if (type == "pod-doc")
			return makeDoc(pod, "pod.fandoc", null)

		// we guess src files, 'cos Fandoc URIs link src by Type, not by .fan file
		// which is nicer, 'cos it means it is impl agnostic - who cares which actual file the src is in!?
		if (type.startsWith("src-")) {
			line := type.toUri.frag?.getRange(4..-1)?.toInt
			type = type.toUri.pathStr
			if (type.toUri.ext == "fan")
				type = type.toUri.path[-1][0..<-4]
			return makeSrc(pod, type[4..-1], line)
		}

		if (type.toUri.frag != null) {
			frag := type.toUri.frag
			type  = type.toUri.name
			return makeDoc(pod, type, frag)
		}
		
		if (type[0].isLower)
			return makeDoc(pod, type, null)			

		if (coreDocNames.contains(pod))
			return makeDoc(pod, type, null)
		
		if (type.toUri.path.size != 1)
			return null ?: (checked ? throw ParseErr("Invalid FantomUri: ${str}") : null)

		slot := type.toUri.ext
		type  = slot == null ? type : type[0..<-(slot.size+1)]
		return makeApi(pod, type, slot)
	}
	
	new static fromStr(Str str, Bool checked := true) {
		uri := (Uri?) null
		try uri = str.toUri
		catch (Err err) return null ?: (checked ? throw err : null)

		fandocUri := fromFantomUri(str, false) ?: fromFandocUri(uri, false)
		return fandocUri ?: (checked ? throw ParseErr("Invalid FandocUri: ${str}") : null)
	}

	Uri toFantomUri() {
		if (isSummary)
			return `${pod}::index`
		
		if (isDoc) {
			// pod.fandoc is actually the summary page
			if (file == "pod.fandoc")
				return `${pod}::index`
			fileName := file.toUri.ext == "fandoc" ? file[0..<-7] : file
			return frag == null ? `${pod}::${fileName}` : `${pod}::${fileName}#${frag}` 
		}

		if (isApi) {
			// if no type is specified, then we actually want the summary page
			if (type == null)
				return `${pod}::index`
			return slot == null ? `${pod}::${type}` : `${pod}::${type}.${slot}`
		}

		if (isSrc)
			return line == null ? `${pod}::src-${type}.fan` : `${pod}::src-${type}.${slot}.fan#line${line}`

		throw Err("WTF")
	}
	
	Uri toFandocUri() {
		if (isSummary)
			return `fandoc:/${pod}/`
		
		if (isDoc) {
			if (file == "pod.fandoc")
				return `fandoc:/${pod}/doc/`
			fileName := file.toUri.ext == "fandoc" ? file[0..<-7] : file
			return frag == null ? `fandoc:/${pod}/doc/${fileName}` : `fandoc:/${pod}/doc/${fileName}#${frag}` 
		}

		if (isApi) {
			if (type == null)
				return `fandoc:/${pod}/api/`
			return slot == null ? `fandoc:/${pod}/api/${type}` : `fandoc:/${pod}/api/${type}#${slot}`
		}

		if (isSrc)
			return line == null ? `fandoc:/${pod}/api/${type}/src` : `fandoc:/${pod}/api/${type}/src#line${line}`

		throw Err("WTF")
	}

	Uri toAbsUrl() {
		if (corePodNames.contains(pod)) {
			coreUrl := `http://fantom.org/doc/`

			if (isSummary)
				return coreUrl + `${pod}/index`
			
			if (isDoc) {
				if (file == "pod.fandoc")
					return coreUrl + `${pod}/index`
				fileName := file.toUri.ext == "fandoc" ? file[0..<-7] : file
				if (fileName.toUri.ext == null)
					fileName += ".html"
				return frag == null ? coreUrl + `${pod}/${fileName}` : coreUrl + `fandoc:/${pod}/${fileName}#${frag}` 
			}
	
			if (isApi) {
				if (type == null)
					return coreUrl + `${pod}/index`
				return slot == null ? coreUrl + `${pod}/${type}.html` : coreUrl + `${pod}/${type}.html#${slot}`
			}
	
			if (isSrc)
				return line == null ? coreUrl + `${pod}/src-${type}.fan` : coreUrl + `${pod}/src-${type}.fan#line${line}`

			throw Err("WTF")
		}
		
		return `http://pods.fantomfactory.org/pods/` + toFandocUri.pathOnly.relTo(`/`)
	}
}
