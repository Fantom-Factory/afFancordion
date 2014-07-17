
internal class CmdExecute : Command {

	override Void runCommand(FixtureCtx fixCtx, Uri cmdUrl, Str cmdText) {
		// can't use Uri.pathStr as it strips off the fragment #TEXT!!!
		fcode := cmdUrl.toStr[cmdUrl.scheme.size+1..-1].replace("#TEXT", cmdText.toCode)
		
		// run the command!
		executeOnFixture(fixCtx.fixtureInstance, fcode)
		
		fixCtx.renderBuf.add(fixCtx.skin.cmdSuccess(cmdText))
	}
}
