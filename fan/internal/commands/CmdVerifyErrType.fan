
internal class CmdVerifyErrType : Command {
	override Void runCommand(FixtureCtx fixCtx, CommandCtx cmdCtx) {
		fcode := cmdCtx.applyVariables

		try {
			// run the command!
			cmdCtx.executeOnFixture(fixCtx.fixtureInstance, fcode)

			failErr := FailErr("Was expecting an Err to be thrown!")
			fixCtx.errs.add(failErr)
			fixCtx.skin.cmdFailure(cmdCtx.cmdText, failErr.msg)

		} catch (Err err) {
			// try to use the real fixture if we can so it notches up the verify count
			test 	:= (fixCtx.fixtureInstance is Test) ? (Test) fixCtx.fixtureInstance : TestImpl()
			errType := cmdCtx.cmdText.endsWith("#") ? cmdCtx.cmdText[0..<-1] : cmdCtx.cmdText 
			try {
				test.typeof.method("verifyEq").callOn(test, [errType, err.typeof.qname])
				fixCtx.skin.cmdSuccess(cmdCtx.cmdText)
				
			} catch (Err err2) {
				fixCtx.errs.add(err2)
				fixCtx.skin.cmdErr(cmdCtx.cmdUri, cmdCtx.cmdText, err)
			}				
		}		
	}
}
