
internal class CmdVerifyErrMsg : Command {
	override Void runCommand(FixtureCtx fixCtx, CommandCtx cmdCtx) {
		fcode := cmdCtx.applyVariables

		try {
			if (fcode.isEmpty && fixCtx.stash["afFancordion.verifyErr"] != null)
				throw fixCtx.stash["afFancordion.verifyErr"]

			// run the command!
			cmdCtx.executeOnFixture(fixCtx.fixtureInstance, fcode)

			failErr := FailErr("Was expecting an Err to be thrown!")
			fixCtx.errs.add(failErr)
			fixCtx.skin.cmdFailure(cmdCtx.cmdText, failErr.msg)

		} catch (Err err) {
			// stash the err for use by CmdVerifyErrMsg
			fixCtx.stash["afFancordion.verifyErr"] = err

			// try to use the real fixture if we can so it notches up the verify count
			test := (fixCtx.fixtureInstance is Test) ? (Test) fixCtx.fixtureInstance : TestImpl()
			try {
				test.typeof.method("verifyEq").callOn(test, [cmdCtx.cmdText, err.msg])
				fixCtx.skin.cmdSuccess(cmdCtx.cmdText)
				
			} catch (Err err2) {
				fixCtx.errs.add(err2)
				fixCtx.skin.cmdErr(cmdCtx.cmdUri, cmdCtx.cmdText, err)
			}				
		}		
	}
}
