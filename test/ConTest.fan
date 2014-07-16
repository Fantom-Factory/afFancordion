using concurrent
using afSizzle

@NoDoc @Fixture
abstract class ConTest : Test {
	
	FixtureResult? result
	
	virtual Void testFixture() {
		runner := ((ConcordionRunner?) ThreadStack.peek("afConcordion.runner", false)) ?: concordionRunner
		result = runner.runFixture(this)

		Actor.locals["afBounce.sizzleDoc"] = SizzleDoc.fromStr(result.resultHtml)
		doTest
		Actor.locals.remove("afBounce.sizzleDoc")
	}
	
	abstract Void doTest()
	
	virtual ConcordionRunner concordionRunner() {
		ConcordionRunner() {
			it.outputDir	= `build/concordion/`.toFile
		}
	}
}
