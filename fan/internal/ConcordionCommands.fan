
internal class ConcordionCommands {
	
	Void doCmd(OutStream out, Uri uri, Str text) {
		
		cmd := uri.path[0]
		param := uri.path[1]
		echo(cmd)
		echo(param)
		echo(text)
		out.print(
"""<%
   pass := true
   try {
     ${cmd}(${param}, ${text.toCode})
     %><span class="success">${efanEsc(text)}</span><%
   } catch {
     pass = false
     %><span class="failure">${efanEsc(text)}</span><%
   }
 
   %>""")
	}
	
	private Str efanEsc(Str text) {
		text
	}
}