using afBounce

** Command: VerifyErrType
** ######################
**
** Similar to 'execute' commands except the expression *must* throw an Err of the specified type.
** 
** Example
** -------
** This should match the qname [sys::ArgErr#]`verifyErrType:dodgyMethod()`.
** 
** This should match the simple name [ArgErr#]`verifyErrType:dodgyMethod()`.
** 
class CmdVerifyErrTypeSuccessTest : ConTest {

	Void dodgyMethod() {
		throw ArgErr("Whoops!")
	}

	override Void doTest() {
		verifyTrue(result.errors.isEmpty)
	}
}
