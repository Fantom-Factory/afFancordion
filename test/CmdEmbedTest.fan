using afBounce

** Command: Embed
** ##############
**
** Embed commands let you print raw HTML.
** 
** Example
** -------
** [Wotever]`embed:poo(#TEXT)`
** 
** NULL: Test a null case: [Eek]`embed:nully`
** 
class CmdEmbedTest : ConTest {

	Obj? nully := null
	
	Str poo(Str text) {
		"""<p class="poo">She said, '${text}'.</p>"""
	}
	
	override Void testFixture() {
		super.testFixture
	}

	override Void doTest() {
		Element("p.poo").verifyTextEq("She said, 'Wotever'.")

		Element("p.null").verifyTextEq("Test a null case: NULL")
	}
}
