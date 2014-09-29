using afBounce

** Command: Set / Execute
** ######################
**
** Set commands should work with full Fantom code expressions.
** 
** Note that this is a backup plan from BeanUtils, and that the field value will *not* be coerced.
** 
** Example
** -------
** If I set 'name' equal to " [Bob]`execute:name = StrBuf().add(#TEXT)` " then I expect 'name' to equal " [Bob]`verify:eq(name.toStr)` "!
** 
class CmdSetCodeExpTest : ConTest {
	StrBuf? name
	
	override Void testFixture() {
		super.testFixture
	}

	override Void doTest() {
		Element("span.success")[0].verifyTextEq("Bob")
		Element("span.success")[1].verifyTextEq("Bob")
	}
}
