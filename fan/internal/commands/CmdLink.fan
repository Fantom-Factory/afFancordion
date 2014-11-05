
** The 'link' command renders a standard HTML <a> tag. 
** It is added with the 'file', 'http', 'https' and 'mailto' schemes.   
** 
** pre>
** ** Be sure to check out [Fantom-Factory]`http://www.fantomfactory.org/`.
** @Fixture
** class ExampleFixture { }
** <pre
internal class CmdLink : Command {
	
	override Bool canFailFast	:= false
	
	override Void runCommand(FixtureCtx fixCtx, CommandCtx cmdCtx) {
		scheme := cmdCtx.cmdScheme.isEmpty ? "" : "${cmdCtx.cmdScheme}:"
		html := fixCtx.skin.a(`${scheme}${cmdCtx.cmdPath}`, cmdCtx.cmdText)
		fixCtx.renderBuf.add(html)
	}
}
