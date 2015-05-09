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
@Fixture { failFast=false }
class CmdVerifyErrMsgFailureTest : ConTest {

	Void dodgyMethod() {
		throw ParseErr("Shucks!")
	}

	override Void doTest() {
		err := result.errors.first
		verifyEq(err.typeof, Type.find("sys::TestErr"))
		verifyEq(err.msg, 	 """Test failed: "Whoops!" [sys::Str] != "Shucks!" [sys::Str]""")
	}
}
