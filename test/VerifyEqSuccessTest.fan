using afBounce

** Command: VerifyEq
** #################
**
** When a 'VerifyEq' command is successful, the text is wrapped in a <span class="success"> tag. 
** 
** Example
** -------
** Concordion says [Kick Ass!]`concordion:verifyEq/greeting`
** 
class VerifyEqSuccessTest : ConTest {
	Str greeting	:= "Kick Ass!"
	
	override Void doTest() {
		Element("span.success").verifyTextEq("Kick Ass!")
	}
}
