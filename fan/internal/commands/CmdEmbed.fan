
** The 'embed' command executes the given function against the fixture and embeds the results as raw HTML.  
** 
** Use it to add extra markup to your fixtures.
** 
** pre>
** ** Kids, don't play with [FIRE!]`embed:danger(#TEXT)`.
** @Fixture
** class ExampleFixture { 
**   Str danger(Str text) {
**     """<span class="danger">${text}</span>"""
**   }
** }
** <pre
internal class CmdEmbed : Command {
	
	override Void runCommand(FixtureCtx fixCtx, CommandCtx cmdCtx) {
		// can't use Uri.pathStr as it strips off the fragment #TEXT!!!
		fcode := cmdCtx.applyVariables

		// run the command!
		html := getFromFixture(fixCtx.fixtureInstance, fcode)
		
		fixCtx.renderBuf.add(html?.toStr ?: "NULL")
	}
}
