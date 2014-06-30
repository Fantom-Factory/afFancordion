
internal class CmdVerify : Command {
	
	private static const Str[] singleArgCmds	:= "eq notEq same notSame type".split
	private static const Str[] doubleArgCmds	:= "true false null notNull".split
	
//		commands["verifyEq"]		= CmdVerifyEq()
//		commands["verifyNotEq"]		= CmdVerifyEq()
//		commands["verifySame"]		= CmdVerifyEq()
//		commands["verifyNotSame"]	= CmdVerifyEq()
//		commands["verifyType"]		= CmdVerifyEq()
//
//		commands["verify"]			= CmdVerifyTrue()
//		commands["verifyTrue"]		= CmdVerifyTrue()
//		commands["verifyFalse"]		= CmdVerifyTrue()
//		commands["verifyNull"]		= CmdVerifyTrue()
//		commands["verifyNotNull"]	= CmdVerifyTrue()

	
	override Str doCmd(Uri cmdUrl, Str cmdText) {
		
		i 	:= cmdUrl.pathStr.index("(")?.minus(1) ?: -1
		cmd := cmdUrl.pathStr[0..i]
		arg	:= (i != -1) ? cmdUrl.pathStr[i+1..-1] : ""

		if (!singleArgCmds.contains(cmd) && !doubleArgCmds.contains(cmd))
			throw CmdNotFoundErr("Could not find Verify command '${cmd}'", singleArgCmds.addAll(doubleArgCmds))
		
		if (arg.startsWith("("))
			arg = arg[1..-1]
		if (arg.endsWith(")"))
			arg = arg[0..-2]
		
		actual   := arg
		expected := cmdText.toCode
		verify	 := "verify${cmd.capitalize}(expected, actual)"
//		if (!arg.trim.isEmpty)
//			arg = ", " + arg

//		echo(cmd + " "  + arg)
		
//		verify := "verify${cmd.capitalize}(expected${arg})"
		
//		TODO: scope the efan so we can run more that one cmd and re-use var names
		
		return
"""<%
   cmdUrl  := ${cmdUrl.toCode}
   cmdText := ${cmdText.toCode}
   try {
       actual   := ${actual}
       expected := ${expected}
       try {
           ${verify}
           %><%= _concordion_skin.success(expected) %><%
       } catch (Err err) {
           _concordion_errors.add(err)
           %><%= _concordion_skin.failure(expected, actual) %><%
       }
   } catch (Err err) {
       _concordion_errors.add(err)
       %><%= _concordion_skin.err(cmdUrl, cmdText, err) %><%
   }
   %>"""
	}
	
	Void main() {
		doCmd(`veri:eq(234)`, "")
		doCmd(`veri:eq`, "")
	}
	
}
