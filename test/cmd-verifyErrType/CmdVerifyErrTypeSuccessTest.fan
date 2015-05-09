using afBounce

** Command: VerifyErrType
** ######################
**
** Similar to 'execute' commands except the expression *must* throw an Err of the specified type.
** 
** Example
** -------
** This should throw an [sys::ArgErr]`verifyErrType:dodgyMethod()`.
** 
class CmdVerifyErrTypeSuccessTest : ConTest {

	Void dodgyMethod() {
		throw ArgErr("Whoops!")
	}

	override Void doTest() {
		verifyTrue(result.errors.isEmpty)
	}
}
