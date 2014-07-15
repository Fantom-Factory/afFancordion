using afBounce

** Command: Test
** ###############
**
** A Test Command links to another concordion fixture. If the fixture passes, it is displayed in green. 
** 
** Example
** -------
**  - Linking to [a Test in error]`test:CmdTestFailureErrTest_TestErr`
**  - Linking to [a Fixture instance]`test:CmdTestFailureErrTest_FixtureFailure`
** 
class CmdTestFailureErrTest : ConTest {

	override Void testFixture() {
		super.testFixture
	}

	override Void doTest() {
		verifyEq(Element("a")[0]["href"], "CmdTestFailureErrTest_TestErr.html")
		verifyEq(Element("span.failure > del.expected a")[0].text, "a Test in error")
		verifyEq(Element("span.failure > span.actual")[0].text, "Boom! Baby!")

		verifyEq(Element("a")[1]["href"], "CmdTestFailureErrTest_FixtureFailure.html")
		verifyEq(Element("span.failure > del.expected a")[1].text, "a Fixture instance")
		verifyEq(Element("span.failure > span.actual")[1].text, """Test failed: "anything" [sys::Str] != "whoopsie" [sys::Str]""")
	}
}

