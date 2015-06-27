using afBounce

//** Wotever
//@Fixture { specification=`fan://afFancordion/test/` }
//class SpecFinderFromPodTest : ConTest {
//	
//	override Void doTest() {
//		Element("p.hotdog").verifyTextEq("Balls of fire! Pod.")
//	}
//}
//
//** Wotever
//@Fixture { specification=`test/` }
//class SpecFinderFromLocalFileTest : ConTest {
//	
//	override Void doTest() {
//		Element("p.hotdog").verifyTextEq("Balls of fire! Local file.")
//	}
//}

** Wotever
@Fixture { specification=`/test/` }
class SpecFinderFromLocalPodTest : ConTest {
	
	override Void doTest() {
		Element("p.hotdog").verifyTextEq("Balls of fire! Local pod.")
	}
}
