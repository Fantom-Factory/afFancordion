using afBounce

** Command: Verify
** ###############
**
** When a 'Verify' command fails, the expected text should be struck out, followed by the actual text - wrapped in a <span class="failure"> tag to highlight it red.
** 
** Example
** -------
** Fancordion says [Kick Ass!]`verifyEq:greeting`
** 
** Fancordion says [Ooops!]`verifyEq:toNull`
** 
@Fixture { failFast=false }
class CmdVerifyEqFailureTest : ConTest {
	Str greeting	:= "Ooops!"
	
	Str? toNull

	override Void testFixture() {
		super.testFixture
	}

	override Void doTest() {
		html := Element("span.failure")[0].innerHtml
		verifyEq(html, "<del class='expected'>Kick Ass!</del><span class='actual'>Ooops!</span>")

		// BugFix: this did give an 'Could not coerce to Null Err'
		html = Element("span.failure")[1].innerHtml
		verifyEq(html, "<del class='expected'>Ooops!</del><span class='actual'/>")
	}
}
