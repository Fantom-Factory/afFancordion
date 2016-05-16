using fandoc

** Implement to create a skin for specification output. 
** Skins are used by Fancordion Commands to generate the HTML result files.
** 
** This class renders bare, but valid, HTML5 markup. Override methods to alter the markup generated.
class FancordionSkin {

	** CSS URLs are rendered in the '<head>' element. 
	** CSS URLs may be added at any stage of rendering as they are added during 'htmlEnd()'.
	Uri[]	cssUrls		:= [,]
	
	** Script URLs are rendered just before the closing '</body>' element. 
	** Script URLs may be added at any stage of rendering as they are added during 'bodyEnd()'.
	Uri[]	scriptUrls	:= [,]
	
	** The 'StrBuf' that this Skin renders to.
	StrBuf	renderBuf	:= StrBuf()

	
	
	// ---- Setup / Tear Down ---------------------------------------------------------------------
	
	** Called before every fixture run.
	** This should reset any state held by the skin, e.g. the 'cssUrls' and 'scriptUrls'.
	virtual Void setup() {
		// create a larger buf based on spec size
		renderBuf = StrBuf(fixtureMeta.specificationSrc.size * 2)
	}

	** Called after every fixture run.
	** This should reset / cleardown any state held by the skin, e.g. the 'cssUrls' and 'scriptUrls'.
	virtual Void tearDown() {
		cssUrls.clear
		scriptUrls.clear		
	}
	

	
	// ---- HTML Methods --------------------------------------------------------------------------
	
	** Starts a '<html>' tag - this should also render the DOCTYPE.
	** 
	** Note that XHTML5 documents require the 'xmlns':
	** 
	**   <html xmlns="http://www.w3.org/1999/xhtml"> 
	virtual This html() {
		write("""<!DOCTYPE html>\n<html xmlns="http://www.w3.org/1999/xhtml">\n""")
	}
	** Ends a '<html>' tag. 
	** This also renders the 'cssUrls' as link tags into the '<head>'.
	virtual This htmlEnd() {
		// insert the CSS links to the <head> tag
		headIdx := renderBuf.toStr.index("</head>")
		cssUrls.unique.eachr |url| { renderBuf.insert(headIdx, render |->| { link(url) } ) }		
		return write("</html>\n")
	}
	
	** Starts a <head> tag - this should also render a <title> tag.
	virtual This head() {
		write("<head>\n\t<title>${fixtureMeta.title.toXml} : Fancordion</title>\n")
		write("<meta charset=\"UTF-8\">\n")
		return this
	}
	virtual This headEnd() { write("</head>\n") }
	
	** Starts a '<body>' tag and renders the breadcrumbs. 
	virtual This body() { write("<body>\n"); return breadcrumbs }
	** Ends a '</body>' tag.
	**  
	** This also calls 'footer()' and renders the 'scriptUrls' as '<script>' tags.
	virtual This bodyEnd() {
		footer
		scriptUrls.unique.each { script(it) }
		return write("</body>\n")
	}
	
	** Starts a section.
	** By default this returns a 'div' with the class 'example':
	** 
	**   <div class="example">
	virtual This section() 		{ write("""<div class="example">\n""") }
	** Ends an *example* section.
	** By default this ends a div:
	** 
	**   </div>
	virtual This sectionEnd()	{ write("</div>\n") }

	** Starts a heading tag, e.g. '<h1>'
	virtual This heading(Int level, Str title, Str? anchorId) {
		id := (anchorId == null) ? Str.defVal : " id=\"${anchorId.toXml}\"" 
		return write("<h${level}${id}>")
	}
	** Ends a heading tag, e.g. '</h1>'
	virtual This headingEnd(Int level) {
		write("""</h${level}>\n""")
	}

	** Starts a '<p>' tag.
	** The admonition is added as a class (lowercase):
	** 
	**   LEAD: Here I am  --> <p class="lead">Here I am</p>
	virtual This p(Str? admonition) { write(admonition == null ? "<p>" : """<p class="${admonition.lower.toXml}">""") }
	** Ends a '</p>' tag.
	virtual This pEnd() 		{ write("</p>\n") }

	** Starts a '<pre>' tag.
	virtual This pre() 			{ write("<pre>") }
	** Ends a '</pre>' tag.
	virtual This preEnd()		{ write("</pre>\n") }
	
	** Starts a '<blockquote>' tag.
	virtual This blockQuote()	{ write("<blockquote>") }
	** Ends a '</blockquote>' tag.
	virtual This blockQuoteEnd() { write("</blockquote>\n") }
	
	** Starts an '<ol>' tag.
	** By default the list style is added as a CSS style attribute:
	** 
	**    <ol style="list-style-type: upper-roman;">
	virtual This ol(OrderedListStyle style)	{ write("""<ol style="list-style-type: ${style.htmlType};">""") }
	** Ends an '</ol>' tag.
	virtual This olEnd() 		{ write("</ol>") }
	
	** Starts a '<ul>' tag.
	virtual This ul()			{ write("<ul>") }
	** Ends a '</ul>' tag.
	virtual This ulEnd() 		{ write("</ul>\n") }
	
	** Starts a '<li>' tag.
	virtual This li()			{ write("<li>") }
	** Ends a '</li>' tag.
	virtual This liEnd() 		{ write("</li>\n") }
	
	** Starts an '<em>' tag.
	virtual This em()			{ write("<em>") }
	** Ends an '</em>' tag.
	virtual This emEnd()		{ write("</em>") }
	
	** Starts a '<strong>' tag.
	virtual This strong()		{ write("<strong>") }
	** Ends a '</strong>' tag.
	virtual This strongEnd()	{ write("</strong>") }
	
	** Starts a '<code>' tag.
	virtual This code()			{ write("<code>") }
	** Ends a '</code>' tag.
	virtual This codeEnd()		{ write("</code>") }
	
	
	
	// ---- Un-Matched HTML ---------------------

	** Renders a CSS '<link>' tag. 
	** 
	** Note that in HTML5 the '<link>' tag is a [Void element]`http://www.w3.org/TR/html5/syntax.html#void-elements` and may be self closing. 
	virtual This link(Uri href)			{ write("""<link rel="stylesheet" type="text/css" href="${href.encode.toXml}" />\n""") }
	
	** Renders a javascript '<script>' tag.
	** 
	** Note that in HTML5 the '<script>' tag is NOT a [Void element]`http://www.w3.org/TR/html5/syntax.html#void-elements` and therefore MUST not be self colsing. 
	virtual This script(Uri src)		{ write("""<script type="text/javascript" src="${src.encode.toXml}"></script>\n""") }
	
	** Renders a complete '<a>' tag.
	virtual This a(Uri href, Str text) 	{ write("""<a href="${href.encode.toXml}">${text.toXml}</a>""") }
	
	** Renders the given text. 
	** By default the text is XML escaped.
	virtual This text(Str text)			{ write(text.toXml) }

	** Renders a complete '<img>' tag. 
	** 
	** Note that in HTML5 the '<img>' tag is a [Void element]`http://www.w3.org/TR/html5/syntax.html#void-elements` and may be self closing. 
	virtual This img(Uri src, Str alt)	{
		srcUrl := copyFile(src.get, `images/`.plusName(src.name))
		return write("""<img src="${srcUrl.encode.toXml}" alt="${alt.toXml}" />""")
	}

	** Renders the breadcrumbs. Makes a call to 'breadcrumbPaths()'
	virtual This breadcrumbs() {
		html := """<span class="breadcrumbs">""" + breadcrumbPaths.join(" > ") |text, href| { renderAnchor(href, text) } + "</span>"
		return write(html)
	}
	
	** Returns an ordered map of URLs to fixture titles to use for the breadcrumbs.
	virtual Uri:Str breadcrumbPaths() {
		paths := Uri:Str[:] { ordered = true}
		metas := (FixtureMeta[]) ThreadStack.elements("afFancordion.fixtureMeta")
		metas.each |meta| {			
			url := meta.resultFile.normalize.uri.relTo(fixtureMeta.resultFile.parent.normalize.uri)
			str := meta.title
			paths[url] = str
		}
		return paths
	}
	
	** Renders a footer.
	** This is (usually) called by 'bodyEnd()'. 
	** By default it just renders a simple link to the Fancordion website.
	virtual This footer() {
		write("<footer>\n" + a(`http://www.fantomfactory.org/pods/afFancordion`, "Fancordion v${Pod.of(this).version}") + "</footer>")
	}


	
	// ---- Table Methods -------------------------------------------------------------------------

	** Starts a '<table>' tag.
	virtual This table(Str? cssClass := null) {
		inTable = true
		return write(cssClass == null ? "<table>\n" : "<table class=\"${cssClass}\">\n")
	}
	** Ends a '</table>' tag.
	virtual This tableEnd() {	inTable = false; return write("</table>")	}
	** Starts a '<tr>' tag.
	virtual This tr() 		{	write("<tr>")		}
	** Ends a '</tr>' tag.
	virtual This trEnd()	{	write("</tr>\n")	}
	** Returns a '<th>' tag.
	virtual This th(Str heading) {
		write("<th>${heading}</th>")
	}
	** Returns a '<td>' tag.
	virtual This td(Str heading) {
		write("<td>${heading}</td>")
	}
	
	
	
	// ---- Test Results --------------------------------------------------------------------------
	
	** Called to render an ignored command.
	virtual This cmdIgnored(Str text) {
		write("""<${cmdElem} class="ignored">${text.toXml}</${cmdElem}>""")
	}

	** Called to render a command success.
	virtual This cmdSuccess(Str text, Bool escape := true) {
		html := escape ? text.toXml : text
		return write("""<${cmdElem} class="success">${html}</${cmdElem}>""")
	}

	** Called to render a command failure.
	virtual This cmdFailure(Str expected, Obj? actual, Bool escape := true) {
		html := escape ? expected.toXml : expected
		return write("""<${cmdElem} class="failure"><del class="expected">${html}</del> <span class="actual">${firstLine(actual?.toStr).toXml}</span></${cmdElem}>""")
	}

	** Called to render a command error.
	virtual This cmdErr(Str cmdUrl, Str cmdText, Err err) {
		write("""<${cmdElem} class="error"><del class="expected">${cmdText.toXml}</del> <span class="actual">${firstLine(err.msg).toXml}</span></${cmdElem}>""")
	}
	
	** Custom commands may use this method as a generic hook into the skin.
	** 
	** By default this method returns an empty string.
	virtual This cmdHook(Uri cmdUrl, Str cmdText, Obj?[]? data) { this }


	
	// ---- Helper Methods ------------------------------------------------------------------------
	
	** Returns meta associated with the current fixture.
	virtual FixtureMeta fixtureMeta() {
		ThreadStack.peek("afFancordion.fixtureMeta")
	}

	** Returns the context associated with the current fixture.
	virtual FixtureCtx fixtureCtx() {
		ThreadStack.peek("afFancordion.fixtureCtx")
	}

	** Copies the given css file to the output dir and adds the resultant URL to 'cssUrls'.
	virtual Void addCss(File cssFile, Bool overwrite := false) {
		cssUrl	:= copyFile(cssFile, `css/`, overwrite)
		cssUrls.add(cssUrl)
	}

	** Copies the given script file to the output dir and adds the resultant URL to 'scriptUrls'.
	virtual Void addScript(File scriptFile, Bool overwrite := false) {
		scriptUrl	:= copyFile(scriptFile, `scripts/`, overwrite)
		scriptUrls.add(scriptUrl)
	}

	** Copies the given file to the destination URL - which is relative to the output folder.
	** Returns a URL to the destination file relative to the current fixture file. 
	** Use this URL for embedding href's in the fixture HTML. Example:
	** 
	**   copyFile(`fan://afFancordion/res/fancordion.css`.get, `etc/fancordion.css`)
	**   --> `../../etc/fancordion.css`
	** 
	** If 'destUrl' is a dir, then the file is copied into it.
	virtual Uri copyFile(File srcFile, Uri destUrl, Bool overwrite := false) {
		if (!destUrl.isPathOnly)
			throw ArgErr(ErrMsgs.urlMustBePathOnly("Dest URL", destUrl, `etc/fancordion.css`))
		if (destUrl.isPathAbs)
			throw ArgErr(ErrMsgs.urlMustNotStartWithSlash("Dest URL", destUrl, `etc/fancordion.css`))
		if (destUrl.isDir)
			destUrl = destUrl.plusName(srcFile.name)

		dstFile := fixtureMeta.baseOutputDir + destUrl
		srcFile.copyTo(dstFile, ["overwrite": overwrite])
		
		return dstFile.normalize.uri.relTo(fixtureMeta.resultFile.parent.normalize.uri)
	}
	
	
	// ---- Private Helpers -----------------------------------------------------------------------
	
	** Renders and returns an '<a>' anchor. 
	public Str renderAnchor(Uri href, Str text) {
		render |->| {
			a(href, text)
		}
	}

	** Renders the contents of the given func into a 'Str' without appending it to the skin's 'renderBuf'.
	** 
	**   syntax: fantom
	**   activeLink := skin.render |->| {
	**       write("<div class='active'>")
	**       a(`http://fantom.org`, "Fantom")
	**       write("</div>")
	**   }
	public Str render(|->| writeFunc) {
		oldBuf := renderBuf
		newBuf := StrBuf()
		renderBuf = newBuf
		writeFunc()
		renderBuf = oldBuf
		return newBuf.toStr
	}
	
	public This write(Str str) {
		renderBuf.add(str)
		return this
	}
	
	private Str firstLine(Str? txt) {
		txt?.splitLines?.exclude { it.trim.isEmpty }?.first ?: Str.defVal
	}
	
	@NoDoc	// 'cos it's a bit of hack!
	protected Bool inTable
	@NoDoc	// 'cos it's a bit of hack!
	protected Bool inPre
	@NoDoc	// 'cos it's a bit of hack!
	protected Str cmdElem() {
		if (inPre)
			return "pre"
		if (inTable)
			return "td"
		return "span"
	}
}

