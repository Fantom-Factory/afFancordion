using afBounce

** Command: VerifyTrue
** ###################
**
** When a 'VerifyTrue' command is successful, the text should be wrapped in a <span class="success"> tag, to highlight it green.
** 
** Example
** -------
** Fancordion says [Kick Ass!]`verify:true(isKickAss)`
** 
class CmdVerifyTrueSuccessTest : ConTest {
	Bool isKickAss	:= true
	
	override Void testFixture() {
		super.testFixture
	}

	override Void doTest() {
		Element("span.success").verifyTextEq("Kick Ass!")
	}
}
