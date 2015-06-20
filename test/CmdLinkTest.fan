using afBounce

** Command: Link
** #############
**
** Link commands should pass through unhindered.
** 
** Example [#top]
** --------------
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
** Example
** -------
** A frag link to [top]`#top`
** 
** Example
** -------
** A link to [IoC Registry]`fandoc:/afIoc/api/Registry`
** 
** Example
** -------
** A link to [sys URI]`sys::Uri`
** 
class CmdLinkTest : ConTest {

	override Void testFixture() {
		super.testFixture
	}

	override Void doTest() {
		link := Link(".example a")[0] 
		link.verifyTextEq("Fantom-Factory")
		verifyEq(link.href, `http://www.fantomfactory.org/`)

		link = Link(".example a")[1] 
		link.verifyTextEq("Google")
		verifyEq(link.href, `https://www.google.com/`)

		link = Link(".example a")[2] 
		link.verifyTextEq("me")
		verifyEq(link.href, `file:CmdLinkTest.fan`)

		link = Link(".example a")[3] 
		link.verifyTextEq("top")
		verifyEq(link.href, `#top`)

		link = Link(".example a")[4] 
		link.verifyTextEq("IoC Registry")
		verifyEq(link.href, `http://pods.fantomfactory.org/pods/afIoc/api/Registry`)

		link = Link(".example a")[5] 
		link.verifyTextEq("sys URI")
		verifyEq(link.href, `http://fantom.org/doc/sys/Uri.html`)
	}
}
