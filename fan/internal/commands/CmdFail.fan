using afBeanUtils::TypeCoercer

** The 'fail' command throws a 'TestErr' with the given message.
** 
** pre>
** ** The meaning of life is [42]`fail:TODO`.
** @Fixture
** class ExampleFixture { }
** <pre
internal class CmdFail : Command {
	override Void runCommand(FixtureCtx fixCtx, CommandCtx cmdCtx) {
		msg := cmdCtx.cmdPath.isEmpty ? "Fail" : cmdCtx.applyVariables
		fixCtx.renderBuf.add(fixCtx.skin.cmdFailure(cmdCtx.cmdText, msg))
		
		fixCtx.errs.add(FailErr(msg))
	}	
}

@NoDoc
const class FailErr : Err {
	new make(Str msg, Err? cause := null) : super(msg, cause) { }
}