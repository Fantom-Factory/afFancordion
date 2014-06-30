using afBeanUtils

internal class Commands {
	private OutStream out
	
	private Str:Command commands
	
	new make(Str:Command commands, OutStream out) {
		this.commands = commands
		this.out = out
	}
	
	Void doCmd(OutStream out, Uri url, Str text) {
		command := commands[url.scheme] ?: throw CmdNotFoundErr(ErrMsgs.cmdNotFound(url.scheme), commands.keys)
		efan	:= command.doCmd(url, text)
		out.print(efan)
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