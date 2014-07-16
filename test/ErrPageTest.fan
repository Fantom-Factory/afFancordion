using afBounce
using concurrent
using afSizzle

** Err Page
** ########
**
** When an unexpected error occurs (such as an Err in the skin), it should be caught and a special 
** error page printed.
** 
** Example
** ------- 
** This should blow up! - [Whoops]`execute:day`
** 
class ErrPageTest : ConTest {

	override Void doTest() {
		msg := Element("pre").text.splitLines[1]
		verifyEq(msg, "sys::Err: There are spiders under my skin!")
	}
	
	override Void testFixture() {
		runner := concordionRunner { it.skinType = MySkin# }
		result := runner.runFixture(this)

		Actor.locals["afBounce.sizzleDoc"] = SizzleDoc.fromStr(result.resultHtml)
		doTest
		Actor.locals.remove("afBounce.sizzleDoc")
	}
}

class MySkin : ClassicSkin {
	override Str htmlEnd() {
		throw Err("There are spiders under my skin!")
	}
}