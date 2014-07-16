using afBeanUtils

internal class Commands {
	private Str:Command commands
	
	new make(Str:Command commands) {
		this.commands = commands
	}
	
	Void doCmd(FixtureCtx fixCtx, Uri cmdUrl, Str cmdText) {
		try {
			command := commands[cmdUrl.scheme] ?: throw CmdNotFoundErr(ErrMsgs.cmdNotFound(cmdUrl.scheme), commands.keys)
			command.doCmd(fixCtx, cmdUrl, cmdText)

		} catch (Err err) {
			fixCtx.errs.add(err)
			fixCtx.renderBuf.add(fixCtx.skin.cmdErr(cmdUrl, cmdText, err))
		}
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