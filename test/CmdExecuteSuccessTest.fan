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
** Calling a method with [#TEXT]`execute:method3(#TEXT, 69)`:
** 
class CmdExecuteSuccessTest : ConTest {

	override Void testFixture() {
		super.testFixture
	}

	Void method1() {
		
	}
	
	Void method2(Str a1, Int a2) {
		
	}

	Void method3(Str text, Int a2) {
		
	}
	
	override Void doTest() {
		Element("span.success")[0].verifyTextEq("Bob")
		Element("span.success")[1].verifyTextEq("Bob")
	}
}
