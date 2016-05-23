using afBounce

** Command: VerifyErrType
** ######################
**
** Similar to 'execute' commands except the expression *must* throw an Err of the specified type.
** 
** Example
** -------
** This should throw an [Whoops!]`verifyErrMsg:dodgyMethod()`.
** 
** Check can verify the err type - [ArgErr]`verifyErrType:`.
** 
class CmdVerifyErrMsgSuccessTest : ConTest {

	Void dodgyMethod() {
		throw ArgErr("Whoops!")
	}

	override Void doTest() {
		verifyTrue(result.errors.isEmpty)
	}
}
