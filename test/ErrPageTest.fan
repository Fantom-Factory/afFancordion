using afBounce

** Err Page
** ########
**
** When an unexpected error occurs (such as an unknown command), it should be caught and a special 
** error page printed.
** 
** Example
** ------- 
** This should blow up! - [Whoops]`doda:day`
** 
class ErrPageTest : ConTest {

	override Void testFixture() {
		super.testFixture
	}

	override Void doTest() {
		msg := Element("pre").text.splitLines[1]
		verifyEq(msg, "afConcordion::CmdNotFoundErr: Could not find Command 'doda'")
	}
}
