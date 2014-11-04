
** A Unit Test - Wow!
class TestComand : Test {
	
	Void test() {
		verify     (Command.isSlotty(this, "verify"))
		verify     (Command.isSlotty(this, "verifyEq(wot, ever)"))
		verifyFalse(Command.isSlotty(this, "Klass.wotever()"))
		verifyFalse(Command.isSlotty(this, "afBouce::Element.wotever()"))
		
		// aha! A sneaky one!
		verifyFalse(Command.isSlotty(this, "verify::Klass.wotever()"))
	}
	
}
