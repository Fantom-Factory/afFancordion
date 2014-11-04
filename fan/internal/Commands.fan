using afBeanUtils

internal class Commands {
	private Str:Command commands
	
	new make(Str:Command commands) {
		this.commands = commands
	}
	
	Bool isCmd(Str? maybe) {
		(maybe == null) ? false : commands.containsKey(maybe)
	}
	
	** We use a Str for cmdUrl so we get the *exact* text and not some URI standard form approximation of. 
	Void doCmd(FixtureCtx fixCtx, Str cmdUrl, Str cmdText, Str[]? tableCols) {
		fixFacet := (Fixture) Type#.method("facet").callOn(fixCtx.fixtureInstance.typeof, [Fixture#])	// Stoopid F4
		try {
			cmdScheme := cmdUrl.split(':')[0]
			if (!cmdUrl.contains(":") || cmdScheme.isEmpty)
				throw CmdNotFoundErr(ErrMsgs.cmdHasNullScheme(cmdUrl), commands.keys)

			command := commands[cmdScheme] ?: throw CmdNotFoundErr(ErrMsgs.cmdNotFound(cmdScheme, cmdUrl), commands.keys)
			
			if (!fixCtx.errs.findAll { it isnot FailErr }.isEmpty && fixFacet.failFast && command.canFailFast)
				fixCtx.renderBuf.add(fixCtx.skin.cmdIgnored(cmdText))
			else {
				cmdPath := cmdUrl[cmdScheme.size+1..-1]
				command.runCommand(fixCtx, CommandCtx(cmdScheme, cmdPath, cmdText, tableCols))
			}

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