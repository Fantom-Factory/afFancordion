
** Implement to mark your Test class as a Concordion Fixture.
mixin Fixture {

	** Runs this Test class as a Concordion fixture. 
	** This method name is prefixed with 'test' so it is picked up by 'fant'.
	virtual Void testFixture() {
		results := concordionRunner.runFixture(this)

		if (!results.errors.isEmpty)
			throw results.errors.first
	}
	
	** Returns a fresh instance of a 'ConcordionRunner'.
	** Override to change default runner values. 
	virtual ConcordionRunner concordionRunner() {
		ConcordionRunner()
	}
}
