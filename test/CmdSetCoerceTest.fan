using afBounce

** Command: Set
** ############
**
** Set commands should be able to coerce Str values to whatever the field needs.
** 
** Example
** -------
** If I set 'name' equal to " [Bob]`set:name` " then I expect 'name' to equal " [Bob]`verify:eq(name)` "!
** 
class CmdSetCoerceTest : ConTest {
	Uri? name
	
	override Void doTest() {
		Element("span.success").verifyTextEq("Bob")
	}
}
