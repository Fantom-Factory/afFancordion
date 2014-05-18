using afEfan

class ConcordionTest : Test {

//	ConcordionEfanMeta?	efanMeta	// TODO:
	ConcordionResults?	concordionResults
	
	virtual Void testFixture() {
		results := ConcordionRunner().runTest(this.typeof, `file:///C:/Projects/Fantom-Factory/Concordion/test/${this.typeof.name}.fan`.toFile)

		this.concordionResults = results
		
		if (!results.errors.isEmpty)
			throw results.errors.first
	}
}
