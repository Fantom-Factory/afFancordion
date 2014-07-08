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

	override Void doTest() {
		fail := Element("span.failure").innerHtml
		verifyEq(fail, "<del class='expected'>Michael Caine</del>")
		Element("span.exceptionMessage").verifyTextEq("java.lang.ClassCastException: fan.sys.Method cannot be cast to fan.sys.Field")
		input := Element("#stackTraceButton1").html
		verifyEq(input, "<input id='stackTraceButton1' type='button' class='stackTraceButton' onclick='javascript:toggleStackTrace(&#39;1&#39;)' value='View Stack'/>")
		Element(".stackTraceEntry").verifyExists
	}
}
