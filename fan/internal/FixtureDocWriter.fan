using fandoc

internal class FixtureDocWriter : DocWriter {
	static private const Str[]	voidTags	:= "area, base, br, col, embed, hr, img, input, keygen, link, menuitem, meta, param, source, track, wbr".split(',')
	static private const Log 	log			:= Utils.getLog(FixtureDocWriter#)
	
	private Bool 	inLink
	private StrBuf?	linkText
	private Bool 	inExample
	
	private Commands 	cmds
	private FixtureCtx	fixCtx
	
	@Deprecated	// all output should go through the Skin
	private OutStream	out
	
	new make(Commands cmds, FixtureCtx fixCtx) {
		this.cmds	= cmds
		this.fixCtx	= fixCtx
		this.out	= fixCtx.renderBuf.out
	}
	
	override Void docStart(Doc doc) {
		append(fixCtx.skin.html)
		append(fixCtx.skin.head)
		append(fixCtx.skin.headEnd)
		append(fixCtx.skin.body)
	}
	
	override Void docEnd(Doc doc) {
		if (inExample) {
			inExample = false
			append(fixCtx.skin.exampleEnd)
		}		
		append(fixCtx.skin.bodyEnd)
		append(fixCtx.skin.htmlEnd)
	}
	
	override Void elemStart(DocElem elem) {
		if (elem.isBlock) out.writeChar('\n')
		
		if (elem.id == DocNodeId.link) {
			inLink = true
			linkText = StrBuf()
			return
		}
		
		if (elem.id == DocNodeId.heading) {
			head := elem as Heading
			
			if (inExample) {
				inExample = false
				append(fixCtx.skin.exampleEnd)
			}
			
			if (head.title.equalsIgnoreCase("Example")) {
				inExample = true
				append(fixCtx.skin.example)
			}
		}

		out.writeChar('<').print(elem.htmlName)
		if (elem.anchorId != null) 
			attr("id", elem.anchorId)
		
//  text,
//  doc,
//  heading,
//  para,
//  pre,
//  blockQuote,
//  orderedList,
//  unorderedList,
//  listItem,
//  emphasis,
//  strong,
//  code,
//  link,
//  image
		switch (elem.id) {
			case DocNodeId.image:
				img := elem as Image
				attr("src", img.uri.toXml)
				attr("alt", img.alt)

			case DocNodeId.orderedList:
				ol := elem as OrderedList
				attr("style", "list-style-type: ${ol.style.htmlType};")

			case DocNodeId.para:
				para := elem as Para
				if (para.admonition != null) {
					attr("class", para.admonition.lower)
				}			
		}
		
		if (isVoidTag(elem.htmlName) && !elem.children.isEmpty)
			log.warn(LogMsgs.voidTagsMustNotHaveContent(elem.htmlName)) 
		out.writeChar('>')
	}
	
	override Void text(DocText docText) {
		if (inLink)
			linkText.out.print(docText.str)
		else
			safeText(docText.str)
	}

	override Void elemEnd(DocElem elem) {
		if (inLink) {
			inLink = false
			cmds.doCmd(fixCtx, ((Link) elem).uri.toUri, linkText.toStr)
			linkText = null
			return
		}
		
		if (elem.id == DocNodeId.link) {
			out.writeChar('<').writeChar('/').print(elem.htmlName).writeChar('>')
			return
		}

		if (!isVoidTag(elem.htmlName) || elem.children.isEmpty)
			out.writeChar('<').writeChar('/').print(elem.htmlName).writeChar('>')

		if (elem.isBlock) out.writeChar('\n')
	}

	private Void attr(Str name, Obj val) {
		out.writeChar(' ').print(name).print("=\"")
		out.writeXml(val.toStr, OutStream.xmlEscQuotes)
		out.writeChar('"')
	}

	private Void safeText(Str s) {
		s.each |Int ch| {
			if (ch == '<') out.print("&lt;")
			else if (ch == '&') out.print("&amp;")
			else out.writeChar(ch)
		}
	}
	
	private Void append(Str s) {
		fixCtx.renderBuf.add(s)
	}
	
	Bool isVoidTag(Str tag) {
		voidTags.contains(tag.lower)
	}
}
