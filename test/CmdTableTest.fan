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
**   Fred Bloggs  Fred        Bloggs
** 
class CmdTableTest : ConTest {
	Str[]? names

	Void split(Str name) {
		names = name.split
	}

	override Void testFixture() {
		super.testFixture
	}

	override Void doTest() {
		Element("span.success")[0].verifyTextEq("Bob")
		Element("span.success")[1].verifyTextEq("Bob")
	}
}
