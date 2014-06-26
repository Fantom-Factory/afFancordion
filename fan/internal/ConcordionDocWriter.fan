using fandoc

internal class ConcordionDocWriter : DocWriter {
	static private const Str[]	voidTags	:= "area, base, br, col, embed, hr, img, input, keygen, link, menuitem, meta, param, source, track, wbr".split(',')
	static private const Log 	log			:= Utils.getLog(ConcordionDocWriter#)
	
	private Bool 	inLink
	private StrBuf?	linkText
	private Bool 	inExample
	
	private OutStream out
	private ConcordionCommands cmds
	
	new make(OutStream out, ConcordionCommands cmds) {
		this.out = out
		this.cmds = cmds
	}
	
	override Void docStart(Doc doc) { } 
	override Void docEnd(Doc doc) {
		if (inExample) {
			inExample = false
			out.print("<%= _concordion_skin.exampleEnd() %>")
		}		
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
				out.print("<%= _concordion_skin.exampleEnd() %>")
			}
			
			if (head.title.equalsIgnoreCase("Example")) {
				inExample = true
				out.print("<%= _concordion_skin.example() %>")
			}
		}

		out.writeChar('<').print(elem.htmlName)
		if (elem.anchorId != null) 
			attr("id", elem.anchorId)
		
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
			cmds.doCmd(out, ((Link) elem).uri.toUri, linkText.toStr)
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
	
	Bool isVoidTag(Str tag) {
		voidTags.contains(tag.lower)
	}
}
