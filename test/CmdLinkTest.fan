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

	override Void doTest() {
		Link("a")[0].verifyTextEq("Fantom-Factory")
		verifyEq(Link("a")[0].href, "http://www.fantomfactory.org/")

		Link("a")[1].verifyTextEq("Google")
		verifyEq(Link("a")[1].href, "https://www.google.com/")

		Link("a")[2].verifyTextEq("me")
		verifyEq(Link("a")[2].href, "file:CmdLinkTest.fan")
	}
}
