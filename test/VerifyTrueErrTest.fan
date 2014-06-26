using afBounce

** Command: VerifyTrue
** ###################
**
** When a 'VerifyTrue' command throws an Err, the expected text should be struck out, followed by the err msg - wrapped in a <span class="failure"> tag to highlight it red.
** There should also be a button to toggle the stack trace on and off.
** 
** Example
** -------
** Concordion says [Kick Ass!]`concordion:verify/isKickAss`
** 
class VerifyTrueErrTest : ConTest {
	Bool isKickAss() { throw Err("Bang!") }

	override Void doTest() {
		fail := Element("span.failure").innerHtml
		verifyEq(fail, "<del class='expected'>Kick Ass!</del>")
		Element("span.exceptionMessage").verifyTextEq("Bang!")
		input := Element("#stackTraceButton1").html
		verifyEq(input, "<input id='stackTraceButton1' type='button' class='stackTraceButton' onclick='javascript:toggleStackTrace(&#39;1&#39;)' value='View Stack'/>")
		Element(".stackTraceEntry").verifyExists
	}
}
