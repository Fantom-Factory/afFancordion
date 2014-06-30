using afBounce

** Command: Verify
** ###############
**
** When a 'Verify' command fails, the expected text should be struck out, followed by the actual text - wrapped in a <span class="failure"> tag to highlight it red.
** 
** Example
** -------
** Concordion says [Kick Ass!]`verify:eq(greeting)`
** 
class VerifyEqFailureTest : ConTest {
	Str greeting	:= "Ooops!"

	override Void doTest() {
		html := Element("span.failure").innerHtml
		verifyEq(html, "<del class='expected'>Kick Ass!</del> Ooops!")
	}
}
