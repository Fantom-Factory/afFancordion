using concurrent

** Implement to create a skin for generated HTML result files.
mixin ConcordionSkin {

	// ---- HTML Methods --------------------------------------------------------------------------
	
	virtual Str html() {
		Actor.locals["afConcordion.skin.buttonId"] 		= 0
		Actor.locals["afConcordion.skin.cssUrls"]		= Uri[,]
		Actor.locals["afConcordion.skin.scriptUrls"]	= Uri[,]
		return """<!DOCTYPE html>\n<html xmlns="http://www.w3.org/1999/xhtml">\n"""
	}
	virtual Str htmlEnd() {
		// Add CSS links to the <head> tag
		headBuf	:= StrBuf()
		headIdx := Actor.locals["afConcordion.skin.headIndex"]
		cssUrls	:= (Uri[]) Actor.locals["afConcordion.skin.cssUrls"]
		cssUrls.each { headBuf.add(link(it)) }
		renderBuf.insert(headIdx, headBuf.toStr)
		
		Actor.locals.remove("afConcordion.skin.buttonId")
		Actor.locals.remove("afConcordion.skin.cssUrls")
		Actor.locals.remove("afConcordion.skin.scriptUrls")
		Actor.locals.remove("afConcordion.skin.headIndex")
		return """</html>\n"""
	}
	
	virtual Str head() {
		buf	:= StrBuf()
		buf.add("<head>\n")
		buf.add("\t<title>${fixtureMeta.title} : Concordion</title>\n")

		addCss(`fan://afConcordion/res/concordion.css`.get)
		addScript(`fan://afConcordion/res/visibility-toggler.js`.get)
		
		Actor.locals["afConcordion.skin.headIndex"] = renderBuf.size + buf.size
		
		buf.add("</head>\n")
		return buf.toStr
	}

	virtual Str link(Uri href) {
		"""<link rel="stylesheet" type="text/css" href="${href}" />\n"""
	}
	
	virtual Str script(Uri src) {
		"""<script type="text/javascript" src="${src}"></script>\n"""
	}
	
	virtual Str body() {
		"""<body>\n\t<main>\n"""
	}
	virtual Str bodyEnd() {
		bodyBuf	:= StrBuf().add("\t</main>\n")
		
		// Add script tags to the end of <body>
		scriptUrls	:= (Uri[]) Actor.locals["afConcordion.skin.scriptUrls"]
		scriptUrls.each { bodyBuf.add(script(it)) }

		return bodyBuf.add("</body>\n").toStr
	}
	
	virtual Str example() {
		"""<div class="example">\n"""
	}
	virtual Str exampleEnd() {
		"""</div>\n"""
	}
	
	
	
	// ---- Test Results --------------------------------------------------------------------------
	
	virtual Str success(Str expected) {
		"""<span class="success">${expected.toXml}</span>"""
	}

	virtual Str failure(Str expected, Obj? actual) {
		"""<span class="failure"><del class="expected">${expected.toXml}</del> ${actual?.toStr?.toXml}</span>"""
	}

	virtual Str err(Uri cmdUrl, Str cmdText, Err err) {
		Actor.locals["afConcordion.skin.buttonId"] = buttonId + 1
		stack := err.traceToStr.splitLines.join("") { "<span class=\"stackTraceEntry\">${it}</span>\n" }
		return
		"""<span class="failure">
		     <del class="expected">${cmdText.toXml}</del>
		   </span>
		   <span class="exceptionMessage">${err.msg.toXml}</span>
		   <input id="stackTraceButton${buttonId}" type="button" class="stackTraceButton" onclick="javascript:toggleStackTrace('${buttonId}')" value="View Stack" />
		   <span class="stackTrace" id="stackTrace${buttonId}">
		     <span>While evaluating command: <code>${cmdUrl}</code></span>
		     <span class="stackTraceExceptionMessage">${err.typeof} : ${err.msg}</span>
		     ${stack}
		   </span>
		   """
	}
	
	
	
	// ---- Helper Methods ------------------------------------------------------------------------
	
	virtual FixtureMeta fixtureMeta() {
		Actor.locals["afConcordion.fixtureMeta"]
	}
	
	virtual Void addCss(File cssFile) {
		cssUrl	:= copyFile(cssFile, `css/`.plusName(cssFile.name))
		cssUrls	:= (Uri[]) Actor.locals["afConcordion.skin.cssUrls"]
		cssUrls.add(cssUrl)
	}

	virtual Void addScript(File scriptFile) {
		scriptUrl	:= copyFile(scriptFile, `scripts/`.plusName(scriptFile.name))
		scriptUrls	:= (Uri[]) Actor.locals["afConcordion.skin.scriptUrls"]
		scriptUrls.add(scriptUrl)
	}

	** Copies the given file to the destination URL - which is relative to the output folder.
	** Returns a URL to the destination file relative to the current fixture file. 
	** Use this URL for embedding href's in the fixture HTML. Example:
	** 
	**   copyFile(`fan://afConcordion/res/concordion.css`.get, `etc/concordion.css`)
	**   --> `../../etc/concordion.css`
	virtual Uri copyFile(File srcFile, Uri destUrl) {
		// TODO: verify args
		// - destDir is rel (and dir!)
		
		dstFile := fixtureMeta.outputDir + destUrl
		srcFile.copyTo(dstFile, ["overwrite": false])
		
		dstRel := dstFile.normalize.uri.relTo(fixtureMeta.outputDir.normalize.uri)
		srcRel := fixtureMeta.templateLoc.parent.relTo(fixtureMeta.baseDir.normalize.uri)
		
		url	:= dstRel.relTo(srcRel)
		return url
	}
	
	
	// ---- Private Helpers -----------------------------------------------------------------------
	
	private Int buttonId() {
		Actor.locals["afConcordion.skin.buttonId"]
	}

	private StrBuf renderBuf() {
		Actor.locals["afConcordion.renderBuf"]
	}
}

internal class ConcordionSkinImpl : ConcordionSkin { }
