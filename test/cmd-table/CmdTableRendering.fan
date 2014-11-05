using afBounce

** Command: Table
** ##############
**
** Ensure tables are still rendered, even if they have been ignored.
** 
** Example
** -------
** Oops... [Error]`verifyEq:"dude"`
**  
**   table:
** 
**   Full Name    First Name  Last Name
**   -----------  ----------- ----------
**   John Smith   John        Smith
**   Fred Bloggs  Freddy      Bloggs
**   Steve Eynon  Steve       Eynon
** 
@Fixture
class CmdTableRendering : ConTest {
	override Void testFixture() {
		super.testFixture
	}

	override Void doTest() {
		Element("table").verifySizeEq(1)
		Element("table.ignored").verifySizeEq(1)
		Element("table.ignored td")[0].verifyTextEq("John Smith")
	}
}
