using fandoc

** Implement to create a skin for specification output. 
** Skins are used by Concordion and its command to generate the HTML result files.
** 
** This mixin by default renders bare, but valid, HTML5 code. Override methods to alter the markup generated.
mixin ConcordionSkin {

	abstract Uri[] cssUrls
	abstract Uri[] scriptUrls
	
	// ---- Setup / Tear Down ---------------------------------------------------------------------
	
	** Called before every fixture run.
	** This should reset any state held by the skin, e.g. the 'cssUrls' and 'scriptUrls'.
	virtual Void setup() { }

	** Called after every fixture run.
	** This should reset / cleardown any state held by the skin, e.g. the 'cssUrls' and 'scriptUrls'.
	virtual Void tearDown() { }
	

	
	// ---- HTML Methods --------------------------------------------------------------------------
	
	** Starts a '<html>' tag - this should also render the DOCTYPE.
	** 
	** Note that XHTML5 documents require the 'xmlns':
	** 
	**   <html xmlns="http://www.w3.org/1999/xhtml"> 
	virtual Str html() {
		"""<!DOCTYPE html>\n<html xmlns="http://www.w3.org/1999/xhtml">\n"""
	}
	** Ends a '<html>' tag. 
	** This also renders the 'cssUrls' as link tags into the '<head>'.
	virtual Str htmlEnd() {
		// insert the CSS links to the <head> tag
		headIdx := renderBuf.toStr.index("</head>")
		cssUrls.eachr { renderBuf.insert(headIdx, link(it)) }
		
		return "</html>\n"
	}
	
	** Starts a <head> tag - this should also render a <title> tag.
	virtual Str head() {
		"<head>\n\t<title>${fixtureMeta.title.toXml} : Concordion</title>\n"
	}
	virtual Str headEnd() { "</head>\n" }
	
	** Starts a '<body>' tag and renders the breadcrumbs. 
	virtual Str body() { "<body>\n" + breadcrumbs }
	** Ends a '</body>' tag.
	**  
	** This also calls 'footer()' and renders the 'scriptUrls' as '<script>' tags.
	virtual Str bodyEnd() {
		bodyBuf	:= StrBuf().add(footer)

		// render the script tags
		scriptUrls.each { bodyBuf.add(script(it)) }

		return bodyBuf.add("</body>\n").toStr
	}
	
	** Starts an *example* section.
	** By default this returns a 'div' with the class 'example':
	** 
	**   <div class="example">
	virtual Str example() 		{ """<div class="example">\n""" }
	** Ends an *example* section.
	** By default this ends a div:
	** 
	**   </div>
	virtual Str exampleEnd()	{ "</div>\n" }

	** Starts a heading tag, e.g. '<h1>'
	virtual Str heading(Int level, Str title, Str? anchorId) {
		id := (anchorId == null) ? Str.defVal : " id=\"${anchorId.toXml}\"" 
		return "<h${level}${id}>"
	}
	** Ends a heading tag, e.g. '</h1>'
	virtual Str headingEnd(Int level) {
		"""</h${level}>\n"""
	}

	** Starts a '<p>' tag.
	** The admonition is added as a class (lowercase):
	** 
	**   LEAD: Here I am  --> <p class="lead">Here I am</p>
	virtual Str p(Str? admonition) { admonition == null ? "<p>" : """<p class="${admonition.lower.toXml}">""" }
	** Ends a '</p>' tag.
	virtual Str pEnd() { "</p>\n" }

	** Starts a '<pre>' tag.
	virtual Str pre() 			{ "<pre>" }
	** Ends a '</pre>' tag.
	virtual Str preEnd()		{ "</pre>\n" }
	
	** Starts a '<blockquote>' tag.
	virtual Str blockQuote()	{ "<blockquote>" }
	** Ends a '</blockquote>' tag.
	virtual Str blockQuoteEnd() { "</blockquote>\n" }
	
	** Starts an '<ol>' tag.
	** By default the list style is added as a CSS style attribute:
	** 
	**    <ol style="list-style-type: upper-roman;">
	virtual Str ol(OrderedListStyle style)	{ """<ol style="list-style-type: ${style.htmlType};">""" }
	** Ends an '</ol>' tag.
	virtual Str olEnd() 		{ "</ol>" }
	
	** Starts a '<ul>' tag.
	virtual Str ul()			{ "<ul>" }
	** Ends a '</ul>' tag.
	virtual Str ulEnd() 		{ "</ul>\n" }
	
	** Starts a '<li>' tag.
	virtual Str li()			{ "<li>" }
	** Ends a '</li>' tag.
	virtual Str liEnd() 		{ "</li>\n" }
	
	** Starts an '<emphasis>' tag.
	virtual Str emphasis()		{ "<emphasis>" }
	** Ends an '</emphasis>' tag.
	virtual Str emphasisEnd()	{ "</emphasis>" }
	
	** Starts an '<strong>' tag.
	virtual Str strong()		{ "<strong>" }
	** Ends an '</strong>' tag.
	virtual Str strongEnd()		{ "</strong>" }
	
	** Starts an '<code>' tag.
	virtual Str code()			{ "<code>" }
	** Ends an '</code>' tag.
	virtual Str codeEnd()		{ "</code>" }
	
	
	
	// ---- Un-Matched HTML ---------------------

	** Renders a complete '<link>' tag. 
	** 
	** Note that in HTML5 the '<link>' tag is a [Void element]`http://www.w3.org/TR/html5/syntax.html#void-elements` and may be self closing. 
	virtual Str link(Uri href)			{ """<link rel="stylesheet" type="text/css" href="${href.encode.toXml}" />\n""" }
	
	** Renders a complete '<script>' tag.
	** 
	** Note that in HTML5 the '<script>' tag is NOT a [Void element]`http://www.w3.org/TR/html5/syntax.html#void-elements` and therefore MUST not be self colsing. 
	virtual Str script(Uri src)			{ """<script type="text/javascript" src="${src.encode.toXml}"></script>\n""" }
	
	** Renders a complete '<a>' tag.
	virtual Str a(Uri href, Str text) 	{ """<a href="${href.encode.toXml}">${text.toXml}</a>""" }
	
	** Renders the given text. 
	** By default the text is XML escaped.
	virtual Str text(Str text)			{ text.toXml }

	** Renders a complete '<img>' tag. 
	** 
	** Note that in HTML5 the '<img>' tag is a [Void element]`http://www.w3.org/TR/html5/syntax.html#void-elements` and may be self closing. 
	virtual Str img(Uri src, Str alt)	{
		srcUrl := copyFile(src.get, `images/`.plusName(src.name))
		return """<img src="${srcUrl.encode.toXml}" alt="${alt.toXml}" />"""
	}

	** Renders the breadcrumbs.
	virtual Str breadcrumbs() {
		"""<span class="breadcrumbs">""" + breadcrumbPaths.join(" > ") |text, href| { a(href, text) } + "</span>"
	}
	
	** Returns an ordered map of URLs to fixture titles to use for the breadcrumbs.
	virtual Uri:Str breadcrumbPaths() {
		paths := Uri:Str[:] { ordered = true}
		metas := (FixtureMeta[]) ThreadStack.elements("afConcordion.fixtureMeta")
		metas.each |meta| {			
			url := meta.resultFile.normalize.uri.relTo(fixtureMeta.resultFile.parent.normalize.uri)
			str := meta.title
			paths[url] = str
		}
		return paths
	}
	
	** Renders a footer.
	** This is (usually) called by 'bodyEnd()'. 
	** By default it just renders a simple link to the Concordion website.
	virtual Str footer() {
		"<footer>\n" + a(`http://www.fantomfactory.org/pods/afConcordion`, "Concordion v${Pod.of(this).version}") + "</footer>"
	}


	
	// ---- Test Results --------------------------------------------------------------------------
	
	** Called to render a command success.
	virtual Str cmdIgnored(Str text) {
		"""<span class="ignored">${text.toXml}</span>"""
	}

	** Called to render a command success.
	virtual Str cmdSuccess(Str text, Bool escape := true) {
		html := escape ? text.toXml : text
		return """<span class="success">${html}</span>"""
	}

	** Called to render a command failure.
	virtual Str cmdFailure(Str expected, Obj? actual, Bool escape := true) {
		html := escape ? expected.toXml : expected
		return """<span class="failure"><del class="expected">${html}</del> <span class="actual">${actual?.toStr?.toXml}</span></span>"""
	}

	** Called to render a command error.
	virtual Str cmdErr(Uri cmdUrl, Str cmdText, Err err) {
		"""<span class="error"><del class="expected">${cmdText.toXml}</del> <span class="actual">${err.msg.toXml}</span></span>"""
	}
	
	** Custom commands may use this method as a generic hook into the skin.
	** 
	** By default this method returns an empty string.
	virtual Str cmdHook(Uri cmdUrl, Str cmdText, Obj?[]? data) { Str.defVal }


	
	// ---- Helper Methods ------------------------------------------------------------------------
	
	** Returns meta associated with the current fixture.
	virtual FixtureMeta fixtureMeta() {
		ThreadStack.peek("afConcordion.fixtureMeta")
	}

	** Returns the context associated with the current fixture.
	virtual FixtureCtx fixtureCtx() {
		ThreadStack.peek("afConcordion.fixtureCtx")
	}

	** Copies the given css file to the output dir and adds the resultant URL to 'cssUrls'.
	virtual Void addCss(File cssFile) {
		cssUrl	:= copyFile(cssFile, `css/`.plusName(cssFile.name))
		cssUrls.add(cssUrl)
	}

	** Copies the given script file to the output dir and adds the resultant URL to 'scriptUrls'.
	virtual Void addScript(File scriptFile) {
		scriptUrl	:= copyFile(scriptFile, `scripts/`.plusName(scriptFile.name))
		scriptUrls.add(scriptUrl)
	}

	** Copies the given file to the destination URL - which is relative to the output folder.
	** Returns a URL to the destination file relative to the current fixture file. 
	** Use this URL for embedding href's in the fixture HTML. Example:
	** 
	**   copyFile(`fan://afConcordion/res/concordion.css`.get, `etc/concordion.css`)
	**   --> `../../etc/concordion.css`
	virtual Uri copyFile(File srcFile, Uri destUrl) {
		if (!destUrl.isPathOnly)
			throw ArgErr(ErrMsgs.urlMustBePathOnly("Dest URL", destUrl, `etc/concordion.css`))
		if (destUrl.isPathAbs)
			throw ArgErr(ErrMsgs.urlMustNotStartWithSlash("Dest URL", destUrl, `etc/concordion.css`))
		if (destUrl.isDir)
			throw ArgErr(ErrMsgs.urlMustNotEndWithSlash("Dest URL", destUrl, `etc/concordion.css`))

		dstFile := fixtureMeta.baseOutputDir + destUrl
		srcFile.copyTo(dstFile, ["overwrite": false])
		
		return dstFile.normalize.uri.relTo(fixtureMeta.resultFile.parent.normalize.uri)
	}
	
	
	// ---- Private Helpers -----------------------------------------------------------------------
	
	private StrBuf renderBuf() {
		fixtureCtx.renderBuf
	}
}
