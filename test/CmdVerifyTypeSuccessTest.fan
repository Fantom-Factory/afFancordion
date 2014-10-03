using afBounce

** Command: Verify
** ###############
**
** Testing 'verify:Type()' command. 
** 
** Example
** -------
** This is a [ Str ]`verifyType:str` and this is an [ Int# ]`verifyType:int`
** 
class CmdVerifyTypeSuccessTest : ConTest {
	Str  str	:= "Kick Ass!"
	Int? int	:= 69

	override Void testFixture() {
		super.testFixture
	}

	override Void doTest() {
		Element("span.success")[0].verifyTextEq("Str")
		Element("span.success")[1].verifyTextEq("Int#")
	}
}
