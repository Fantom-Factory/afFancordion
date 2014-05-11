using afEfan

class ConcordionTest : Test {

//	private Test test := TestInstance()
//
//	Void verifyEq(Obj? a, Obj? b) {
//		test.verifyEq(a, b)
//	}

	EfanMetaData? efanMetaData
	
	Void testFixture() {
		
		ConcordionRunner().runTest(this.typeof, `file:///C:/Projects/Fantom-Factory/Concordion/test/${this.typeof.name}.fan`.toFile)

		
	}
}

//internal class TestInstance : Test { }
