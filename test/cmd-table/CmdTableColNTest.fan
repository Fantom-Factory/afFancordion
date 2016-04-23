using afBounce

** Command: Table
** ##############
**
** Testing the col[N] command
** 
** Example
** -------
** 
**   table:
**   col[n]+verifyEq:names[#COL]
** 
**   Full Name    First Name  Last Name
**   -----------  ----------- ----------
**   John Smith   John        Smith
** 
@Fixture { failFast=false }
class CmdTableColNTest : ConTest {
	Str[]? names := ["John Smith", "John", "Smith"]

	override Void testFixture() {
		super.testFixture
	}

	override Void doTest() {
		Element("td.success")[0].verifyTextEq("John Smith")
		Element("td.success")[1].verifyTextEq("John")
		Element("td.success")[2].verifyTextEq("Smith")
	}
}
