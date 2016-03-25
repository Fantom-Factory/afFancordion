using afBounce

** Command: Verify
** ###############
**
** Test that commands can be executed inside <pre> tags.
** 
** Example
** -------
** Fancordion says:
** 
**   verifyEq:greeting
**   Kick Ass!
** 
class CmdInPreTest : ConTest {
	Str greeting	:= "Kick Ass!"

	override Void testFixture() {
		super.testFixture
	}

	override Void doTest() {
		Element("pre.success").verifyTextEq("Kick Ass!")
	}
}
