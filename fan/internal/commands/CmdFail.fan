using afBeanUtils::TypeCoercer

** The 'fail' command throws a 'TestErr' with the given message.
** 
** pre>
** ** The meaning of life is [42]`fail:TODO`.
** @Fixture
** class ExampleFixture { }
** <pre
internal class CmdFail : Command {
	override Void runCommand(FixtureCtx fixCtx, CommandCtx cmdCtx, Uri cmdUrl, Str cmdText) {
		msg := pathStr(cmdUrl).isEmpty ? "Fail" : cmdCtx.applyVariables(pathStr(cmdUrl))
		fixCtx.renderBuf.add(fixCtx.skin.cmdFailure(cmdText, msg))
		
		fixCtx.errs.add(FailErr(msg))
	}	
}

@NoDoc
const class FailErr : Err {
	new make(Str msg, Err? cause := null) : super(msg, cause) { }
}