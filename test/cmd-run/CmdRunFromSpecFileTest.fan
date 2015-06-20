using afBounce

class CmdRunFromSpecFileTest : ConTest {
	Bool isKickAss	:= true
	
	override Void testFixture() {
		super.testFixture
	}

	override Void doTest() {
		Element("span.success").verifyTextEq("Kick Ass!")
	}
}

