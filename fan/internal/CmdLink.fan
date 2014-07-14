
internal class CmdLink : Command {
	
	override Void doCmd(FixtureCtx fixCtx, Uri cmdUrl, Str cmdText) {
		// FIXME: route through skin
//		html := fixCtx.skin.a(cmdUrl, cmdText)
		html := """<a href="${cmdUrl}">${cmdText}</a>"""
		fixCtx.renderBuf.add(html)
	}
}
