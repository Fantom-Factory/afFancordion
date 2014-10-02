
** The 'execute' command calls a method on the fixture. 
** The cmd is compiled as Fantom code so may be *any* valid Fantom code.
** 
** Any occurrences of the token '#TEXT' are replaced with the command / link text.
** 
** pre>
** ** [The end has come.]`execute:initiateShutdownSequence(42, #TEXT, "/tmp/end.txt".toUri)`
** @Fixture
** class ExampleFixture {
**   Void initiateShutdownSequence(Int num, Str cmdText, Uri url) {
**     ...
**   } 
** }
** <pre
internal class CmdExecute : Command {

	override Void runCommand(FixtureCtx fixCtx, Uri cmdUrl, Str cmdText) {
		fcode := pathStr(cmdUrl).replace("#TEXT", cmdText.toCode)
		
		// run the command!
		executeOnFixture(fixCtx.fixtureInstance, fcode)
		
		fixCtx.renderBuf.add(fixCtx.skin.cmdSuccess(cmdText))
	}
}
