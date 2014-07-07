using concurrent
using afSizzle

abstract class ConTest : Test, ConcordionTest {
	
	ConcordionResults? concordionResults
	
	override Void testConcordionFixture() {
		this.concordionResults = ConcordionRunner().runTest(this)

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
