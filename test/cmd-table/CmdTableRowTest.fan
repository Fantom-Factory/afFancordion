using afBounce

** Command: Table
** ##############
**
** Testing the 'row' command.
** 
** Example
** -------
** Stuff to do with splitting a full name into first and last names:
** 
**   table:
**   row+execute:split(#COL[0], #COL[1], #COL[2], #COLS)
** 
**   Full Name    First Name  Last Name
**   -----------  ----------  ---------
**   John Smith   John        Smith
**   Fred Bloggs  Freddy      Bloggs
**   Steve Eynon  Steve       Eynon
** 
@Fixture { failFast=false }
class CmdTableRowTest : ConTest {

	Void split(Str full, Str first, Str last, Str[] cols) {
		verifyEq([full, first, last], cols)
//		if (first == "Steve")
//			throw Err("Argh!")
		verifyEq(full.split[0], first)
		verifyEq(full.split[1], last)
	}

	override Void testFixture() {
		super.testFixture
	}

	override Void doTest() {
		Element("tr.success td")[0].verifyTextEq("John Smith")
		Element("tr.success td")[1].verifyTextEq("John")
		Element("tr.success td")[2].verifyTextEq("Smith")

		Element("tr.error td")[0].verifyTextEq("Fred Bloggs")
		Element("tr.error td")[1].verifyTextEq("Freddy")
		Element("tr.error td")[2].verifyTextEq("Bloggs")
		Element("tr.error td .expected").verifyTextEq("[Fred Bloggs, Freddy, Bloggs]")
	}
}
