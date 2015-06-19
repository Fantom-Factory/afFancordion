using afBeanUtils

@NoDoc
class Commands {
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
			command	  := (Command?) null

			if (!cmdUrl.contains(":") || cmdScheme.isEmpty)
				// FIXME: this is a fudge
				// allow frag links
				if (cmdUrl.startsWith("#")) {
					cmdScheme = ""
					command = CmdLink()
				} else
					throw CmdNotFoundErr(ErrMsgs.cmdHasNullScheme(cmdUrl), commands.keys)

			if (command == null)
				command = commands[cmdScheme] ?: throw CmdNotFoundErr(ErrMsgs.cmdNotFound(cmdScheme, cmdUrl), commands.keys)
			
			ignore := !fixCtx.errs.findAll { it isnot FailErr }.isEmpty
			if (ignore && fixFacet.failFast && command.canFailFast)
				fixCtx.renderBuf.add(fixCtx.skin.cmdIgnored(cmdText))

			else { 
				cmdPath	  := cmdUrl.contains(":") ? cmdUrl[cmdScheme.size+1..-1] : cmdUrl
				command.runCommand(fixCtx, CommandCtx(cmdScheme, cmdPath, cmdText, tableCols, ignore))
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