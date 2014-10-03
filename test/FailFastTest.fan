using afBounce

** Fail Fast Commands
** ##################
**
** Fail fast - should one command fail, the rest are ignored. 
** 
** Example
** -------
** [This command fails]`verifyEq:oops`
** 
** [This command is ignored]`verifyEq:oops`
** 
** Links like [this one]`http://www.fantomfactory.org/` still work.
** 
class FailFastTest : ConTest {

	Str oops	:= "Oops"
	
	override Void testFixture() {
		super.testFixture
	}

	override Void doTest() {
		Element("span.failure")[0].verifyTextEq("This command failsOops")
		Element("span.failure").verifySizeEq(1)
		
		Element("span.ignored")[0].verifyTextEq("This command is ignored")
		Element("span.ignored").verifySizeEq(1)

		Element(".example a")[0].verifyTextEq("this one")
	}
}
