
** [anything]`verify:eq(anything)`
@Fixture
class CmdRunFailureErrTest_TestErr : Test, FixtureTest {
	Str anything() { 
		throw ArgErr("Boom! Baby!")
	}
}