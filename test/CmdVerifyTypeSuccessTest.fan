using afBounce

** Command: Verify
** ###############
**
** Testing 'verify:Type()' command. 
** 
** Example
** -------
** This is a [ Str ]`verify:type(str)` and this is an [ Int# ]`verify:type(int)`
** 
class CmdVerifyTypeSuccessTest : ConTest {
	Str  str	:= "Kick Ass!"
	Int? int	:= 69

	override Void testConcordionFixture() {
		super.testConcordionFixture
	}

	override Void doTest() {
		Element("span.success")[0].verifyTextEq("Str")
		Element("span.success")[1].verifyTextEq("Int#")
	}
}
