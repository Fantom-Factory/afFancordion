using afBounce

** Command: Set
** ############
**
** Set commands should set fields to the wrapped value.
** 
** Example
** -------
** If I set 'name' equal to " [Bob]`set:name` " then I expect 'name' to equal " [Bob]`verify:eq(name)` "!
** 
class CmdSetSuccessTest : ConTest {
	Str? name := "Wotever"
	
	override Void testFixture() {
		super.testFixture
	}

	override Void doTest() {
		Element("span.success")[0].verifyTextEq("Bob")
		Element("span.success")[1].verifyTextEq("Bob")
	}
}
