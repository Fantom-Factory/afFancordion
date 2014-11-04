using afBounce

** Command: Table Rows
** ###################
** 
** Example
** -------
** 
**   table:
**   verifyRows:results
** 
**   Names
**   ------
**   john
**   ringo
**   george
** 
class CmdTableRowsTooFew : ConTest {
	Str[] results	:= "john ringo".split
	
	override Void testFixture() {
		super.testFixture
	}

	override Void doTest() {
		Element("td.success")[0].verifyTextEq("john")
		Element("td.success")[1].verifyTextEq("ringo")
		Element("td.failure .expected")[0].verifyTextEq("george")
	}
}
