using afBounce

** Command: Set
** ############
**
** Set commands should be able to coerce Str values to whatever the field needs.
** 
** Note this only works for simple expressions that can be parsed by BeanUtils.
** 
** Example
** -------
** If I set 'name' equal to " [Bob]`set:name` " then I expect 'name' to equal " [Bob]`verifyEq:name` "!
** 
class CmdSetCoerceTest : ConTest {
	Uri? name
	
	override Void testFixture() {
		super.testFixture
	}

	override Void doTest() {
		Element("span.success")[0].verifyTextEq("Bob")
		Element("span.success")[1].verifyTextEq("Bob")
	}
}
