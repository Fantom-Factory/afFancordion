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
**   col[0]+execute:split(#TEXT)
**   col[1]+verifyEq:names[0]
**   col[2]+verifyEq:names[1]
** 
**   Full Name    First Name  Last Name
**   -----------  ----------- ----------
**   John Smith   John        Smith
**   Fred Bloggs  Freddy      Bloggs
**   Steve Eynon  Steve       Eynon
** 
@Fixture { failFast=false }
class CmdTableColumnTest : ConTest {
	Str[]? names

	Void split(Str name) {
		if (name.startsWith("Steve"))
			throw Err("Argh!")
		names = name.split
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

		Element("td.error")[0].verifyTextContains("Steve EynonErr: Argh!")
		Element("td.failure")[1].verifyTextEq("SteveFred")
		Element("td.failure")[2].verifyTextEq("EynonBloggs")
	}
}
