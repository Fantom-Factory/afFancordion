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
@Fixture { failFast=false }
class CmdVerifyErrTypeFailureTest : ConTest {

	Void dodgyMethod() {
		throw ParseErr("Whoops!")
	}

	override Void doTest() {
		err := result.errors.first
		verifyEq(err.typeof, Type.find("sys::TestErr"))
		verifyEq(err.msg, 	 """Test failed: "sys::ArgErr" [sys::Str] != "sys::ParseErr" [sys::Str]""")
	}
}
