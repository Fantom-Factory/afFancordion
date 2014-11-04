using afBounce

** Command: Table
** ##############
**
** Partial Matches
** ###############
** 
** Username searches return partial matches, i.e. all usernames 
** containing the search string are returned.
** 
** Example
** -------
** Given these users:
** 
**   table:
**   col[0]+execute:addUser(#TEXT)
** 
**   Username
**   ---------------
**   john.lennon
**   ringo.starr
**   george.harrison
**   paul.mcartney
** 
** Searching for [arr]`execute:doSearch(#TEXT)` will return:
** 
**   table:
**   verifyRows:searchResults
** 
**   Matching Usernames
**   ------------------
**   ringo.starr
**   george.whoops
** 
class CmdTableRows : ConTest {
	Str[] usernamesInSystem	:= [,]
	Str[] searchResults		:= [,]

	Void addUser(Str username) {
		usernamesInSystem.add(username)
	}

	Void doSearch(Str name) {
		searchResults = usernamesInSystem.findAll { it.contains(name) }
	}
	
	override Void testFixture() {
		super.testFixture
	}

	override Void doTest() {
		Element("td.success")[4].verifyTextEq("ringo.starr")
		Element("td.failure")[0].verifyTextEq("george.whoopsgeorge.harrison")
	}
}
