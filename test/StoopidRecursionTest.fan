using afBounce
using concurrent

** Prevent Stoopid Recursion
** #########################
**
** Sometimes you do something stoopid - lets guard against it. 
** 
** Example
** -------
** [Do some stoopid test recursion!]`run:StoopidRecursionTest`
** 
class StoopidRecursionTest : ConTest {

	static const AtomicInt depth := AtomicInt(0) 
	
	override Void testFixture() {
		if (depth.getAndIncrement > 1)
			throw Err("Recursion!")
		super.testFixture
	}

	override Void doTest() {
		Element(".exceptionMessage").verifyTextEq("Err: Recursion Error - Fixture 'afFancordion::StoopidRecursionTest' calls itself!")
	}
}
