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
**   col[1]+verify:eq(names[0])
**   col[2]+verify:eq(names[1])
** 
**   Full Name    First Name  Last Name
**   -----------  ----------- ----------
**   John Smith   John        Smith
**   Steve Eynon  Steve       Eynon
**   Fred Bloggs  Freddy      Bloggs
** 
@Fixture { failFast=false }
class CmdTableTest : ConTest {
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

		Element("td.error")[0].verifyTextEq("Steve Eynon")
		Element("td.failure")[0].verifyTextEq("Steve")
		Element("td.failure")[1].verifyTextEq("Eynon")

		Element("span.success")[6].verifyTextEq("Fred Bloggs")
		Element("span.success")[7].verifyTextEq("Fred")
		Element("span.success")[8].verifyTextEq("Bloggs")
	}
}
