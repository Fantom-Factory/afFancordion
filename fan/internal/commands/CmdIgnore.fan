
** 'todo' simply ignores the command. Handy for commenting out tests. 
** 
** pre>
** syntax: fantom
** 
** ** Questions:
** ** - [Why is the sky blue?]`todo:run:BlueSkyFixture#`.
** @Fixture
** class ExampleFixture { }
** <pre
internal class CmdIgnore : Command {
	
	override Bool canFailFast	:= false
	
	override Void runCommand(FixtureCtx fixCtx, CommandCtx cmdCtx) {
		fixCtx.skin.cmdIgnored(cmdCtx.cmdText)
	}
}
