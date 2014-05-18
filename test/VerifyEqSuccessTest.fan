
** Command: VerifyEq
** #################
**
** When a 'VerifyEq' command is successful, the text is wrapped in a <span class="success"> tag. 
** 
** Example
** -------
** Concordion says [Kick Ass!]`concordion:verifyEq/greeting`
** 
class VerifyEqSuccessTest : ConcordionTest {
	Str greeting	:= "Kick Ass!"
	
	override Void testFixture() {
		super.testFixture
		
		result := concordionResults.resultFile.readAllStr
		verify(result.contains("""<span class="success">Kick Ass!</span>"""), result)
	}
}
