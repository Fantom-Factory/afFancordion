
internal class CmdVerify : Command {
	
	private static const Str[] doubleArgCmds	:= "eq notEq type".split 
	private static const Str[] singleArgCmds	:= "true false null notNull".split
	private static const Str:Type coerceTo		:= ["eq":Str#, "notEq":Str#, "type":Obj#, "true":Bool#, "false":Bool#, "null":Obj?#, "notNull":Obj?#]

	override Str doCmd(Uri cmdUrl, Str cmdText) {
		
		i 	:= cmdUrl.pathStr.index("(")?.minus(1) ?: -1
		cmd := cmdUrl.pathStr[0..i]
		arg	:= (i != -1) ? cmdUrl.pathStr[i+1..-1].trim : ""

		if (!singleArgCmds.contains(cmd) && !doubleArgCmds.contains(cmd))
			throw CmdNotFoundErr(ErrMsgs.verifyCmdNotFound(cmd), singleArgCmds.addAll(doubleArgCmds))
		
		if (arg.startsWith("("))
			arg = arg[1..-1]
		if (arg.endsWith(")"))
			arg = arg[0..-2]
		
		aType	 := coerceTo[cmd].qname + "#"
		actual   := "afBeanUtils::TypeCoercer().coerce(${arg}, ${aType})"
		expected := (cmd == "type") ? findTypeCode(cmdText) : cmdText.toCode
		
		if (cmd == "type") {
			temp    := actual
			actual   = expected
			expected = temp
		}

		verify 	 := ""
		if (singleArgCmds.contains(cmd)) {
			cName := cmd.equalsIgnoreCase("true") ? "" : cmd 
			verify = "test.verify${cName.capitalize}(actual)"
		}

		if (doubleArgCmds.contains(cmd)) {
			verify = "test.verify${cmd.capitalize}(expected, actual)"
		}
		
		return
"""<% |->| { // scope the local variables so we can embed the command more than once
          cmdUrl  := ${cmdUrl.toCode}
          cmdText := ${cmdText.toCode}
          try {
              actual      := ${actual}
              expected    := ${expected}
              try {
                  %><%# use the real fixture if we can so it notches up the verify count %><%
                  test := (_concordion_fixture is Test) ? (Test) _concordion_fixture : afConcordion::TestImpl()
                  ${verify}
                  %><%= _concordion_skin.success(cmdText) %><%
              } catch (Err err) {
                  _concordion_errors.add(err)
                  %><%= _concordion_skin.failure(cmdText, actual) %><%
              }
          } catch (Err err) {
              _concordion_errors.add(err)
              %><%= _concordion_skin.err(cmdUrl, cmdText, err) %><%
          }
      }() %>"""
	}
	
	private static Str findTypeCode(Str cmdText) {
		cmdText = cmdText.trim
		cmdText = cmdText.contains("::") ? cmdText : "sys::${cmdText}" 
		cmdText = cmdText.endsWith("#")  ? cmdText[0..<-1] : cmdText
		return "Type.find(${cmdText.toCode}, true)"
	}
}

@NoDoc
class TestImpl : Test { }
