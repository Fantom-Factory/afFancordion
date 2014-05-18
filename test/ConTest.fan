
class ConTest : ConcordionTest {
	
	override Void testFixture() {
		ConcordionRunner().runTest(this.typeof, `file:///C:/Projects/Fantom-Factory/Concordion/test/${this.typeof.name}.fan`.toFile)
	}

}
