
internal class CmdLink : Command {
	
	override Void doCmd(FixtureCtx fixCtx, Uri cmdUrl, Str cmdText) {
		html := fixCtx.skin.a(cmdUrl, cmdText)
		fixCtx.renderBuf.add(html)
	}
}
