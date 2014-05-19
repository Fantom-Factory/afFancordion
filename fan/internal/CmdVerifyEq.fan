
class CmdVerifyEq : Command {
	
	override Void doCmd(OutStream out, Str cmd, Str param, Str text) {
		out.print(
"""<%
   expect := ${text.toCode}		
   try {
       actual := ${param}
       try {
           ${cmd}(expect, actual)
           %><span class="success"><%= actual.toXml %></span><%
       } catch (Err err) {
           _concordion_errors.add(err)
           %><span class="failure"><span class="expected"><%= expect.toXml %></span> <%= actual.toXml %></span><%
       }
   } catch (Err err) {
       _concordion_errors.add(err)
       %><span class="failure"><%= expect.toXml %></span><%
   }
   %>""")
	}
}
