using afBounce

** Command: Set
** ############
**
** Should something go wrong when executing a 'set' command, it should be caught and rendered as an Err.
** 
** Example
** -------
** My name is [Michael Caine]`set:name`
** 
class CmdSetErrTest : ConTest {
	Void name() { }

	override Void testFixture() {
		super.testFixture
	}

	override Void doTest() {
		fail := Element("span.error").innerHtml
		verifyEq(fail, "<del class='expected'>Michael Caine</del>")
		Element("span.exceptionMessage").verifyTextEq("Can not *set* a value on method: afFancordion::CmdSetErrTest.name")
		input := Element("#stackTraceButton1").html
		verifyEq(input, "<input id='stackTraceButton1' type='button' class='stackTraceButton' onclick='javascript:toggleStackTrace(&#39;1&#39;)' value='View Stack'/>")
		Element(".stackTraceEntry").verifyExists
	}
}
