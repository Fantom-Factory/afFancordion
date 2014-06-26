using afEfan

abstract class ConcordionTest : Test {

//	ConcordionEfanMeta?	efanMeta	// TODO:
	ConcordionResults?	concordionResults
	
	virtual Void testConcordionFixture() {
		// TODO: this method should save the result file
		results := concordionRunner.runTest(this.typeof)

		this.concordionResults = results
		
		if (!results.errors.isEmpty)
			throw results.errors.first
	}
	
	** Returns a fresh instance of a 'ConcordionRunner'.
	** Override to change default runner values. 
	virtual ConcordionRunner concordionRunner() {
		ConcordionRunner()
	}
}
