using concurrent
using afSizzle

abstract class ConTest : ConcordionTest {
	
	override Void testFixture() {
		this.concordionResults = ConcordionRunner().runTest(this.typeof)

		result := concordionResults.result
		echo(result)
		Actor.locals["afBounce.sizzleDoc"] = SizzleDoc.fromStr(result)
		doTest
		Actor.locals.remove("afBounce.sizzleDoc")
	}
	
	abstract Void doTest()	
}
