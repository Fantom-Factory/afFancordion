using afBounce

** Command: Verify
** ###############
**
** This test is to make sure multiple verify statements can be executed on the same page. 
** 
** Example
** -------
** This statement is [true]`verify:true(isTrue)`
** 
** And this statement is [false]`verify:false(isFalse)`
** 
** And this one is [true]`verify:true(isTrue)` again
class CmdVerifyX2Test : ConTest {
	Bool isTrue		:= true
	Bool isFalse	:= false
	
	override Void doTest() {
		Element("span.success")[0].verifyTextEq("true")
		Element("span.success")[1].verifyTextEq("false")
		Element("span.success")[2].verifyTextEq("true")
	}
}
