
** Implement to convert a Test class into a Concordion fixture.
@Fixture
mixin FixtureTest {

	** Runs this Test class as a Concordion fixture. 
	** This method name is prefixed with 'test' so it is picked up by 'fant' and other test runners.
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
