
** [anything]`verifyEq:anything`
@Fixture
class CmdRunFailureErrTest_TestErr : FixtureTest {
	Str anything() { 
		throw ArgErr("Boom! Baby!")
	}
}