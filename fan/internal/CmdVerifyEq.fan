
class CmdVerifyEq : Command {
	
	override Void doCmd(OutStream out, Str cmd, Str param, Str text) {
		out.print(
"""<%
   expected := ${text.toCode}		
   try {
       actual := ${param}
       try {
           ${cmd}(expected, actual)
           %><%= _concordion_writeSuccess(expected) %><%
       } catch (Err err) {
           _concordion_errors.add(err)
           %><%= _concordion_writeFailure(expected, actual) %><%
       }
   } catch (Err err) {
       _concordion_errors.add(err)
       %>_concordion_writeErr(expected, err)<%
   }
   %>""")
	}
}
