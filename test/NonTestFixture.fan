
** Non-Test Fixture
** ################
**
** Test that Concordion fixtures do not have to extend 'sys::Test'.
** 
** Example
** -------
** Concordion is [Awesome!]`verify:eq(awesome)`
** 
@Fixture @NoDoc
class NonTestFixture {
	Str awesome	:= "Awesome!"
}

internal class NonTestFixtureTest : Test {
	Void testFixture() {
		results := ConcordionRunner().runFixture(NonTestFixture())
		if (!results.errors.isEmpty)
			throw results.errors.first
	}
}