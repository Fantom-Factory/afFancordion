using afBounce

** Command: Verify
** ###############
**
** When a 'Verify' command fails, the expected text should be struck out, followed by the actual text - wrapped in a <span class="failure"> tag to highlight it red.
** 
** Example
** -------
** Fancordion says [Kick Ass!]`verify:eq(greeting)`
** 
class CmdVerifyEqFailureTest : ConTest {
	Str greeting	:= "Ooops!"

	override Void testFixture() {
		super.testFixture
	}

	override Void doTest() {
		html := Element("span.failure").innerHtml
		verifyEq(html, "<del class='expected'>Kick Ass!</del><span class='actual'>Ooops!</span>")
	}
}
