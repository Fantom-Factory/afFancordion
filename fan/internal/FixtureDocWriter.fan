using fandoc

internal class FixtureDocWriter : DocWriter {
//	static private const Log 	log			:= Utils.getLog(FixtureDocWriter#)
	
	private Bool 	inLink
	private StrBuf?	linkText
	private Bool 	inExample
	
	private Commands 	cmds
	private FixtureCtx	fixCtx
	
	new make(Commands cmds, FixtureCtx fixCtx) {
		this.cmds	= cmds
		this.fixCtx	= fixCtx
	}
	
	override Void docStart(Doc doc) {
		fixCtx.skin.setup
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
		fixCtx.skin.tearDown
	}
	
	override Void elemStart(DocElem elem) {
		switch (elem.id) {
			case DocNodeId.link:
				inLink = true
				linkText = StrBuf()
				
			case DocNodeId.heading:
				head := elem as Heading
				
				if (inExample) {
					inExample = false
					append(fixCtx.skin.exampleEnd)
				}
				
				if (head.title.equalsIgnoreCase("Example")) {
					inExample = true
					append(fixCtx.skin.example)
				}
				
				append(fixCtx.skin.heading(head.level, head.title, head.anchorId))
			
			case DocNodeId.para:
				para := elem as Para
				append(fixCtx.skin.p(para.admonition))
			
			case DocNodeId.pre:
				append(fixCtx.skin.pre)
			
			case DocNodeId.blockQuote:
				append(fixCtx.skin.blockQuote)
			
			case DocNodeId.orderedList:
				list := elem as OrderedList
				append(fixCtx.skin.ol(list.style))
			
			case DocNodeId.unorderedList:
				append(fixCtx.skin.ul)

			case DocNodeId.listItem:
				append(fixCtx.skin.li)

			case DocNodeId.emphasis:
				append(fixCtx.skin.emphasis)

			case DocNodeId.strong:
				append(fixCtx.skin.strong)

			case DocNodeId.code:
				append(fixCtx.skin.code)

			case DocNodeId.image:
				image := elem as Image
				append(fixCtx.skin.img(image.uri.toUri, image.alt))

			default:
				throw Err("WTF is a ${elem.id} element???")
		}
	}
	
	override Void text(DocText docText) {
		if (inLink) {
			linkText.out.print(docText.str)
			return
		}

		append(fixCtx.skin.text(docText.str))
	}

	override Void elemEnd(DocElem elem) {
		switch (elem.id) {
			case DocNodeId.link:
				inLink = false
				cmds.doCmd(fixCtx, ((Link) elem).uri.toUri, linkText.toStr)
				linkText = null
				
			case DocNodeId.heading:
				head := elem as Heading
				append(fixCtx.skin.headingEnd(head.level))
		
			case DocNodeId.para:
				para := elem as Para
				append(fixCtx.skin.pEnd)
			
			case DocNodeId.pre:
				append(fixCtx.skin.preEnd)
			
			case DocNodeId.blockQuote:
				append(fixCtx.skin.blockQuoteEnd)
			
			case DocNodeId.orderedList:
				list := elem as OrderedList
				append(fixCtx.skin.olEnd)
			
			case DocNodeId.unorderedList:
				append(fixCtx.skin.ulEnd)

			case DocNodeId.listItem:
				append(fixCtx.skin.liEnd)

			case DocNodeId.emphasis:
				append(fixCtx.skin.emphasisEnd)

			case DocNodeId.strong:
				append(fixCtx.skin.strongEnd)

			case DocNodeId.code:
				append(fixCtx.skin.codeEnd)

			case DocNodeId.image:
				null?.toStr

			default:
				throw Err("WTF is a ${elem.id} element???")
		}
	}

//	private Void attr(Str name, Obj val) {
//		out.writeChar(' ').print(name).print("=\"")
//		out.writeXml(val.toStr, OutStream.xmlEscQuotes)
//		out.writeChar('"')
//	}
//
//	private Void safeText(Str s) {
//		s.each |Int ch| {
//			if (ch == '<') out.print("&lt;")
//			else if (ch == '&') out.print("&amp;")
//			else out.writeChar(ch)
//		}
//	}
	
	private Void append(Str s) {
		fixCtx.renderBuf.add(s)
	}
}
