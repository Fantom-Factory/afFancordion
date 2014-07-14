using afBeanUtils

internal class Commands {
	private Str:Command commands
	
	new make(Str:Command commands) {
		this.commands = commands
	}
	
	Void doCmd(FixtureCtx fixCtx, Uri url, Str text) {
		command := commands[url.scheme] ?: throw CmdNotFoundErr(ErrMsgs.cmdNotFound(url.scheme), commands.keys)
		command.doCmd(fixCtx, url, text)
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