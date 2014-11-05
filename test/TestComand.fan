
** A Unit Test - Wow!
class TestComand : Test {
	
	Void test() {
		verify     (CommandCtx.isSlotty(this, "verify"))
		verify     (CommandCtx.isSlotty(this, "verifyEq(wot, ever)"))
		verifyFalse(CommandCtx.isSlotty(this, "Klass.wotever()"))
		verifyFalse(CommandCtx.isSlotty(this, "afBouce::Element.wotever()"))
		
		// aha! A sneaky one!
		verifyFalse(CommandCtx.isSlotty(this, "verify::Klass.wotever()"))
	}
	
}
