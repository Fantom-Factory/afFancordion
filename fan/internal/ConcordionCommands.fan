
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
				CmdVerifyEq().doCmd(out, cmd, param, text)

			default:
				throw Err("WTF? $cmd")	// TODO:
		}
		
	}

}