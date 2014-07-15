using afBounce

** Command: Link
** #############
**
** Link commands should pass through unhindered.
** 
** Example
** -------
** A http link to [Fantom-Factory]`http://www.fantomfactory.org/`
** 
** Example
** -------
** A https link to [Google]`https://www.google.com/`
** 
** Example
** -------
** A file link to [me]`file:CmdLinkTest.fan`
** 
class CmdLinkTest : ConTest {

	override Void testFixture() {
		super.testFixture
	}

	override Void doTest() {
		link := Link(".example a")[0] 
		link.verifyTextEq("Fantom-Factory")
		verifyEq(link.href, "http://www.fantomfactory.org/")

		link = Link(".example a")[1] 
		link.verifyTextEq("Google")
		verifyEq(link.href, "https://www.google.com/")

		link = Link(".example a")[2] 
		link.verifyTextEq("me")
		verifyEq(link.href, "file:CmdLinkTest.fan")
	}
}
