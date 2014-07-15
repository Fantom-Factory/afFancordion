
** [anything]`verify:eq(anything)`
@Fixture
class CmdTestFailureErrTest_TestErr : Test, FixtureTest {
	Str anything() { 
		throw ArgErr("Boom! Baby!")
	}
}