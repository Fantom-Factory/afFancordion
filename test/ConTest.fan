using concurrent
using afSizzle

abstract class ConTest : ConcordionTest {
	
	override Void testConcordionFixture() {
		this.concordionResults = ConcordionRunner().runTest(this.typeof)

		result := concordionResults.result
		Actor.locals["afBounce.sizzleDoc"] = SizzleDoc.fromStr(result)
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
