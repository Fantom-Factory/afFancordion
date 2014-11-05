using afBounce

** Command: Table
** ##############
**
** Allow 2D verifyRows
** 
** Example
** -------
** Given these users:
** 
**   table:
**   verifyRows:results
** 
**   First  Last
**   ------ ------
**   ringo  starr
**   george whoops
** 
class CmdTable2dVerifyRows : ConTest {
	Obj results	:= [["ringo", "starr"], ["george", "whoops"], ["fred", "bloggs"]]
	
	override Void testFixture() {
		super.testFixture
	}

	override Void doTest() {
		Element("td.success")[0].verifyTextEq("ringo")
		Element("td.success")[1].verifyTextEq("starr")
		Element("td.success")[2].verifyTextEq("george")
		Element("td.success")[3].verifyTextEq("whoops")

		Element("td.failure")[0].verifyTextEq("fred")
		Element("td.failure")[1].verifyTextEq("bloggs")
	}
}
