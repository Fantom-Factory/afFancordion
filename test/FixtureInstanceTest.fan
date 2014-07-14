using afBounce

** Fixture Instance
** ################
**
** Test that *this* very instance is used for the 'verify' and 'set' commands.
** Because the tests could very well rely on state created in the setup() method. 
** 
** Example
** -------
** [Verify Command]`verify:eq(verCmd)`
** 
internal class FixtureInstanceTest : ConTest {
	Str? verCmd
	
	override Void setup() {
		verCmd = "Verify Command"
	}
	
	override Void doTest() {
		Element("span.success")[0].verifyTextEq("Verify Command")
	}
}
