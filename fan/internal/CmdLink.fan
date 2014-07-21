
** The 'link' command renders a standard HTML <a> tag. 
** It is added with the 'file', 'http', 'https' and 'mailto' schemes.   
** 
** pre>
** ** Be sure to check out [Fantom-Factory]`http://www.fantomfactory.org/`.
** @Fixture
** class ExampleFixture { }
** <pre
internal class CmdLink : Command {
	
	override Void runCommand(FixtureCtx fixCtx, Uri cmdUrl, Str cmdText) {
		html := fixCtx.skin.a(cmdUrl, cmdText)
		fixCtx.renderBuf.add(html)
	}
}
