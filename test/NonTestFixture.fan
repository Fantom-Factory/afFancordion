
** Non-Test Fixture
** ################
**
** Test that Fancordion fixtures do not have to extend 'sys::Test'.
** 
** Example
** -------
** Fancordion is [Awesome!]`verifyEq:awesome`
** 
@Fixture @NoDoc
class NonTestFixture {
	Str awesome	:= "Awesome!"
}

internal class NonTestFixtureTest : Test {
	Void testFixture() {
		results := FancordionRunner().runFixture(NonTestFixture())
		if (!results.errors.isEmpty)
			throw results.errors.first
	}
}