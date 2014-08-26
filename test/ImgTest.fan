using afBounce

** Image Test
** ##########
**
** Test that images get copied over and rendered correctly. 
** 
** Example
** -------
** Check out my Alien!
** 
** ![Alien-Head]`fan://afFancordion/test/alienFactory.png`
** 
class ImgTest : ConTest {
	
	override Void testFixture() {
		super.testFixture
	}

	override Void doTest() {
		verifyEq(Element("img")["src"], "../images/alienFactory.png")
		verifyEq(Element("img")["alt"], "Alien-Head")
		
		imgFile := result.fixtureMeta.baseOutputDir + `images/alienFactory.png` 
		verify(imgFile.exists)
	}
}
