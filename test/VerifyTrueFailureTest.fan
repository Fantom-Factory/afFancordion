using afBounce

** Command: VerifyTrue
** ###################
**
** When a 'VerifyTrue' command fails, the expected text should be struck out, followed by the actual text - wrapped in a <span class="failure"> tag to highlight it red.
** 
** Example
** -------
** Concordion says [Kick Ass!]`verify:true(isKickAss)`
** 
class VerifyTrueFailureTest : ConTest {
	Bool isKickAss	:= false

	override Void doTest() {
		html := Element("span.failure").innerHtml
		verifyEq(html, "<del class='expected'>Kick Ass!</del> false")
	}
}
