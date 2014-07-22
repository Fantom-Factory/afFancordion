using afBounce

** Command: Run
** ############
**
** A Test Command links to another concordion fixture. If the fixture fails, it is displayed in red. 
** 
** Example
** -------
**  - Linking to [a Test in error]`run:CmdRunFailureErrTest_TestErr`
**  - Linking to [a Fixture instance]`run:CmdRunFailureErrTest_FixtureFailure`
** 
@Fixture
class CmdRunFailureErrTest : ConTest {

	override Void testFixture() {
		super.testFixture
	}

	override Void doTest() {
		verifyEq(Element("ul a")[0]["href"], "CmdRunFailureErrTest_TestErr.html")
		verifyEq(Element("ul span.failure > del.expected a")[0].text, "a Test in error")
		verifyEq(Element("ul span.failure > span.actual")[0].text, "Boom! Baby!")

		verifyEq(Element("ul a")[1]["href"], "CmdRunFailureErrTest_FixtureFailure.html")
		verifyEq(Element("ul span.failure > del.expected a")[1].text, "a Fixture instance")
		verifyEq(Element("ul span.failure > span.actual")[1].text, """Test failed: "anything" [sys::Str] != "whoopsie" [sys::Str]""")
	}
}

