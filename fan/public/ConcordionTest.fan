using afEfan

abstract class ConcordionTest : Test {

//	ConcordionEfanMeta?	efanMeta	// TODO:
	ConcordionResults?	concordionResults
	
	virtual Void testFixture() {
		// TODO: this method should save the result file
		results := ConcordionRunner().runTest(this.typeof, `file:///C:/Projects/Fantom-Factory/Concordion/test/${this.typeof.name}.fan`.toFile)

		this.concordionResults = results
		
		if (!results.errors.isEmpty)
			throw results.errors.first
	}
}
