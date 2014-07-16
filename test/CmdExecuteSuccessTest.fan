using afBounce

** Command: Execute
** ################
**
** Execute commands should call the given method.
** 
** Example
** -------
** Calling a method with [no args]`execute:method1`:
** 
** Example
** -------
** Calling a method with [some args]`execute:method2("dingdong", 69)`:
** 
** Example
** -------
** Calling a method [with #TEXT]`execute:method3(#TEXT, 42)`:
** 
class CmdExecuteSuccessTest : ConTest {

	Str? res1
	Str? res2
	Str? res3
	
	override Void testFixture() {
		super.testFixture
	}

	Void method1() {
		res1 = "called"
	}
	
	Void method2(Str a1, Int a2) {
		res2 = "${a1}-${a2}"		
	}

	Void method3(Str a1, Int a2) {
		res3 = "${a1}-${a2}"		
	}

	override Void doTest() {
		Element("span.success")[0].verifyTextEq("no args")
		verifyEq(res1, "called")
		
		Element("span.success")[1].verifyTextEq("some args")
		verifyEq(res2, "dingdong-69")

		Element("span.success")[2].verifyTextEq("with #TEXT")
		verifyEq(res3, "with #TEXT-42")
	}
}
