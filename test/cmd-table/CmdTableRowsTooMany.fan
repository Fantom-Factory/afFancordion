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
class CmdTableRowsTooMany : ConTest {
	Str[] results	:= "john ringo george paul".split
	
	override Void testFixture() {
		super.testFixture
	}

	override Void doTest() {
		Element("td.success")[0].verifyTextEq("john")
		Element("td.success")[1].verifyTextEq("ringo")
		Element("td.success")[2].verifyTextEq("george")
		Element("td.failure .actual")[0].verifyTextEq("paul")		
	}
}
