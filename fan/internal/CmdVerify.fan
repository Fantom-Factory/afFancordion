
internal class CmdVerify : Command {
	
	private static const Str[] doubleArgCmds	:= "eq notEq same notSame type".split
	private static const Str[] singleArgCmds	:= "true false null notNull".split

	override Str doCmd(Uri cmdUrl, Str cmdText) {
		
		i 	:= cmdUrl.pathStr.index("(")?.minus(1) ?: -1
		cmd := cmdUrl.pathStr[0..i]
		arg	:= (i != -1) ? cmdUrl.pathStr[i+1..-1] : ""

		if (!singleArgCmds.contains(cmd) && !doubleArgCmds.contains(cmd))
			throw CmdNotFoundErr(ErrMsgs.verifyCmdNotFound(cmd), singleArgCmds.addAll(doubleArgCmds))
		
		if (arg.startsWith("("))
			arg = arg[1..-1]
		if (arg.endsWith(")"))
			arg = arg[0..-2]
		
		actual   := arg
		expected := cmdText.toCode
		
		verify 	 := ""		
		if (singleArgCmds.contains(cmd)) {
			if (cmd.equalsIgnoreCase("true"))
				cmd = ""
			verify = "((Test) _concordion_testInstance).verify${cmd.capitalize}(actual)"
		}

		if (doubleArgCmds.contains(cmd)) {
			verify = "((Test) _concordion_testInstance).verify${cmd.capitalize}(expected, actual)"
		}
		
		return
"""<% |->| { // scope the local variables so we can embed the command more than once
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
      }() %>"""
	}	
}
