
internal class ConcordionCommands {
	private OutStream out
	
	new make(OutStream out) {
		this.out = out
	}
	
	Void doCmd(OutStream out, Uri uri, Str text) {
		cmd := uri.path[0]
		param := uri.path[1]
		
		switch (cmd.lower) {
			case "verifyeq":
				verifyEq(cmd, param, text)
		    
			default:
				throw Err("WTF? $cmd")	// TODO:
		}
		
	}
		
	Void verifyEq(Str cmd, Str param, Str text) {
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