using afBounce

** Command: Table
** ##############
**
** Table commands are special form of 'pre' markup.
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
		Element("td.success")[0].verifyTextEq("John Smith")
		Element("td.success")[1].verifyTextEq("John")
		Element("td.success")[2].verifyTextEq("Smith")

		Element("td.success")[3].verifyTextEq("Fred Bloggs")
		Element("td.failure")[0].verifyTextEq("FreddyFred")
		Element("td.success")[4].verifyTextEq("Bloggs")

		Element("td.error"  )[0].verifyTextContains("Steve EynonArgh!")
		Element("td.failure")[1].verifyTextEq("SteveFred")
		Element("td.failure")[2].verifyTextEq("EynonBloggs")
	}
}
