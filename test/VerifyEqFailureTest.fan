using afBounce

** Command: VerifyEq
** #################
**
** When a 'VerifyEq' command fails, the expected text should be struck out, followed by the actual text - wrapped in a <span class="failure"> tag to highlight it red.
** 
** Example
** -------
** Concordion says [Kick Ass!]`concordion:verifyEq/greeting`
** 
class VerifyEqFailureTest : ConTest {
	Str greeting	:= "Ooops!"

	override Void doTest() {
		html := Element("span.failure").innerHtml
		verifyEq(html, "<del class='expected'>Kick Ass!</del> Ooops!")
	}
}
