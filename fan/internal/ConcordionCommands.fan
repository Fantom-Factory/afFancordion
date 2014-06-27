using afBeanUtils

internal class ConcordionCommands {
	private OutStream out
	
	private Str:Command commands
	
	new make(Str:Command commands, OutStream out) {
		this.commands = commands
		this.out = out
	}
	
	Void doCmd(OutStream out, Uri uri, Str text) {
		cmd 	:= uri.path[0]
		param	:= uri.path[1]
		command := commands[cmd] ?: throw CmdNotFoundErr(ErrMsgs.cmdNotFound(cmd), commands.keys)
		command.doCmd(out, cmd, param, text)
	}

}

@NoDoc
const class CmdNotFoundErr : Err, NotFoundErr {
	override const Str?[] 	availableValues
	override const Str		valueMsg	:= "Available Commands:"
	
	new make(Str msg, Obj?[] availableValues, Err? cause := null) : super(msg, cause) {
		this.availableValues = availableValues.map { it?.toStr }.sort
	}
	
	override Str toStr() {
		NotFoundErr.super.toStr		
	}
}