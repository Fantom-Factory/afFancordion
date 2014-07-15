using afBounce

** Command: Test
** ###############
**
** A Test Command links to another concordion fixture. If the fixture passes, it is displayed in green. 
** 
** Example
** -------
**  - Linking to [another Test instance]`test:CmdTestSuccessTest_Test`
**  - Linking to [a Fixture instance]`test:CmdTestSuccessTest_Fixture`
** 
class CmdTestSuccessTest : ConTest {
	Str greeting	:= "Kick Ass!"

	override Void testFixture() {
		super.testFixture
	}

	override Void doTest() {
		verifyEq(Element("a")[0]["href"], "CmdTestSuccessTest_Test.html")
		verifyEq(Element("span.success > a")[0].text, "another Test instance")

		verifyEq(Element("a")[1]["href"], "CmdTestSuccessTest_Fixture.html")
		verifyEq(Element("span.success > a")[1].text, "a Fixture instance")
	}
}

