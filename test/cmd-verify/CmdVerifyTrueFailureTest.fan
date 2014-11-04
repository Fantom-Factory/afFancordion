using afBounce

** Command: VerifyTrue
** ###################
**
** When a 'VerifyTrue' command fails, the expected text should be struck out, followed by the actual text - wrapped in a <span class="failure"> tag to highlight it red.
** 
** Example
** -------
** Fancordion says [Kick Ass!]`verifyTrue:isKickAss`
** 
class CmdVerifyTrueFailureTest : ConTest {
	Bool isKickAss	:= false

	override Void testFixture() {
		super.testFixture
	}

	override Void doTest() {
		html := Element("span.failure").innerHtml
		verifyEq(html, "<del class='expected'>Kick Ass!</del><span class='actual'>false</span>")
	}
}
