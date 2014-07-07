
mixin ConcordionTest {

	virtual Void testConcordionFixture() {
		results := concordionRunner.runTest(this)

		if (!results.errors.isEmpty)
			throw results.errors.first
	}
	
	** Returns a fresh instance of a 'ConcordionRunner'.
	** Override to change default runner values. 
	virtual ConcordionRunner concordionRunner() {
		ConcordionRunner()
	}
}
