using afBounce

** Command: Fail
** #############
**
** A simple command that fails the test with the given message.
** 
** Example
** -------
** The meaning of life is [42]`fail:TO#DO`
** 
** The meaning of life is [39]`fail:`
** 
class CmdFailTest : ConTest {

	override Void testFixture() {
		super.testFixture
	}

	override Void doTest() {
		html := Element("span.failure")[0].innerHtml
		verifyEq(html, "<del class='expected'>42</del><span class='actual'>TO#DO</span>")

		html = Element("span.failure")[1].innerHtml
		verifyEq(html, "<del class='expected'>39</del><span class='actual'>Fail</span>")
	}
}
