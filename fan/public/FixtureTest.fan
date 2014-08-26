
** Extend to convert a Test class into a Fancordion fixture.
@Fixture
class FixtureTest : Test {

	** Runs this Test class as a Fancordion fixture. 
	** This method name is prefixed with 'test' so it is picked up by 'fant' and other test runners.
	virtual Void testFixture() {
		runner := FancordionRunner.current ?: fancordionRunner
		result := runner.runFixture(this)

		if (!result.errors.isEmpty)
			throw result.errors.first
	}
	
	** Returns a fresh instance of a 'FancordionRunner'.
	** 
	** Override to change default runner values and / or supply suite setup & teardown methods.
	virtual FancordionRunner fancordionRunner() {
		FancordionRunner()
	}
}
