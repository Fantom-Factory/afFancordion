

class CmdVerifyErrMsg : Command {
	override Void runCommand(FixtureCtx fixCtx, CommandCtx cmdCtx) {
		fcode := cmdCtx.applyVariables

		try {
			// run the command!
			cmdCtx.executeOnFixture(fixCtx.fixtureInstance, fcode)

			failErr := FailErr("Was expecting an Err to be thrown!")
			fixCtx.errs.add(failErr)
			fixCtx.renderBuf.add(fixCtx.skin.cmdFailure(cmdCtx.cmdText, failErr.msg))

		} catch (Err err) {
			// try to use the real fixture if we can so it notches up the verify count
			test := (fixCtx.fixtureInstance is Test) ? (Test) fixCtx.fixtureInstance : TestImpl()
			try {
				test.typeof.method("verifyEq").callOn(test, [cmdCtx.cmdText, err.msg])
				fixCtx.renderBuf.add(fixCtx.skin.cmdSuccess(cmdCtx.cmdText))
				
			} catch (Err err2) {
				fixCtx.errs.add(err2)
				fixCtx.renderBuf.add(fixCtx.skin.cmdErr(cmdCtx.cmdUri, cmdCtx.cmdText, err))
			}				
		}		
	}
}
