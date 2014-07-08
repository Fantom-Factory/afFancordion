using concurrent
using afSizzle

abstract class ConTest : Test, Fixture {
	
	FixtureResult? result
	
	override Void testFixture() {
		this.result = ConcordionRunner().runFixture(this)

		Actor.locals["afBounce.sizzleDoc"] = SizzleDoc.fromStr(result.resultHtml)
		doTest
		Actor.locals.remove("afBounce.sizzleDoc")
	}
	
	abstract Void doTest()
	
	override ConcordionRunner concordionRunner() {
		ConcordionRunner() {
			it.outputDir	= `build/concordion/`.toFile
		}
	}
}
