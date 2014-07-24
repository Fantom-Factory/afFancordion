using fandoc

internal class FixtureDocWriter : DocWriter {
	
	private Bool 	inLink
	private Bool 	inPre
	private StrBuf?	linkText
	private Bool 	inExample
	
	private Commands 	cmds
	private FixtureCtx	fixCtx
	
	new make(Commands cmds, FixtureCtx fixCtx) {
		this.cmds	= cmds
		this.fixCtx	= fixCtx
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
				
				// TODO: contribute section titles
				// even better, contribute functions! so that titles can have custom content
				if (head.title.equalsIgnoreCase("Example")) {
					inExample = true
					append(fixCtx.skin.example)
				}
				
				append(fixCtx.skin.heading(head.level, head.title, head.anchorId))
			
			case DocNodeId.para:
				para := elem as Para
				append(fixCtx.skin.p(para.admonition))
			
			case DocNodeId.pre:
				inPre = true
				linkText = StrBuf()
			
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
		if (inLink || inPre) {
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
				
			case DocNodeId.pre:
				inPre	  = false
				preText  := linkText.toStr
				linkText  = null
				preLines := preText.splitLines
				cmdUrl	 := Uri(preLines.first.trim, false)
				if (!preLines.isEmpty && cmds.isCmd(cmdUrl?.scheme)) {
					append(fixCtx.skin.pre)
					preLines.removeAt(0)
					preText = preLines.join("\n")
					cmds.doCmd(fixCtx, cmdUrl, preText.trim)
					append(fixCtx.skin.preEnd)
					
				} else {
					append(fixCtx.skin.pre)
					append(fixCtx.skin.text(preText))
					append(fixCtx.skin.preEnd)
				}
			
			case DocNodeId.heading:
				head := elem as Heading
				append(fixCtx.skin.headingEnd(head.level))
		
			case DocNodeId.para:
				para := elem as Para
				append(fixCtx.skin.pEnd)
			
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
	
	private Void append(Str s) {
		fixCtx.renderBuf.add(s)
	}
}
