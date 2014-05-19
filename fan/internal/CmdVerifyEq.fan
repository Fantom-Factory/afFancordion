
class CmdVerifyEq : Command {
	
	override Void doCmd(OutStream out, Str cmd, Str param, Str text) {
		out.print(
"""<%
   pass := true
   try {
     ${cmd}(${param}, ${text.toCode})
     %><span class="success">${escXml(text)}</span><%
   } catch {
     pass = false
     %><span class="failure">${escXml(text)}</span><%
   }
 
   %>""")
	}
}
