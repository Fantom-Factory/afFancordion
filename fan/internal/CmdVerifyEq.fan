
internal class CmdVerifyEq : Command {
	
	override Void doCmd(OutStream out, Str cmd, Str param, Str text) {
		out.print(
"""<%
   expected := ${text.toCode}		
   expression := "${cmd}/${param.toCode(null)}"
   try {
       actual := ${param}
       try {
           ${cmd}(expected, actual)
           %><%= _concordion_skin.success(expected) %><%
       } catch (Err err) {
           _concordion_errors.add(err)
           %><%= _concordion_skin.failure(expected, actual) %><%
       }
   } catch (Err err) {
       _concordion_errors.add(err)
       %><%= _concordion_skin.err(expected, expression, err) %><%
   }
   %>""")
	}
}
