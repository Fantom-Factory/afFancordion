using concurrent
using afSizzle

@NoDoc @Fixture
abstract class ConTest : Test {
	
	FixtureResult? result
	
	virtual Void testFixture() {
		runner := ((FancordionRunner?) ThreadStack.peek("afFancordion.runner", false)) ?: fancordionRunner
		result = runner.runFixture(this)

		Actor.locals["afBounce.sizzleDoc"] = SizzleDoc.fromStr(result.resultHtml)
		doTest
		Actor.locals.remove("afBounce.sizzleDoc")
	}
	
	virtual Void doTest() { }
	
	virtual FancordionRunner fancordionRunner() {
		FancordionRunner() {
			it.outputDir	= `build/fancordion/`.toFile
		}
	}
}
