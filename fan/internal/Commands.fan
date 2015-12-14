using afBeanUtils

@NoDoc
class Commands {
	private Str[]				commandHints	:= Str[,]
	private |Str, Str->Bool|:Command commands	:= |Str, Str->Bool|:Command[:]
	
	new make(Obj:Command commands) {
		commands.each |cmd, key| {
			if (key is Str) {
				this.commandHints.add(key)
				this.commands[|Str cmdUrl, Str cmdScheme->Bool| { 
					cmdScheme.equalsIgnoreCase(key)
				}.toImmutable] = cmd
				return
			}
			if (key is |Str->Bool| || key is |Str, Str->Bool|) {
				this.commands[key.toImmutable] = cmd
				return
			}
			throw ArgErr("What do I do with this key??? ${key.typeof.qname} - ${key}")
		}
	}

	Bool isCmd(Str? maybe) {
		(maybe == null) ? false : commands.keys.any { it(maybe, maybe) }
	}

	** We use a Str for cmdUrl so we get the *exact* text and not some URI standard form approximation of. 
	Void doCmd(FixtureCtx fixCtx, Str cmdUrl, Str cmdText, Int? tableRow, Str[]? tableCols) {
		fixFacet := (Fixture) Type#.method("facet").callOn(fixCtx.fixtureInstance.typeof, [Fixture#])	// Stoopid F4
		try {
			cmdScheme := cmdUrl.contains(":") ? cmdUrl.split(':').first : ""
			command	  := commands.find |val, key| { key(cmdUrl, cmdScheme) }

			if (command == null)
				 throw CmdNotFoundErr(ErrMsgs.cmdNotFound(cmdScheme, cmdUrl), commandHints)
			
			ignore := !fixCtx.errs.findAll { it isnot FailErr }.isEmpty && fixFacet.failFast
			if (ignore && command.canFailFast)
				fixCtx.skin.cmdIgnored(cmdText)

			else { 
				cmdPath	  := cmdUrl.contains(":") ? cmdUrl[cmdScheme.size+1..-1] : cmdUrl
				command.runCommand(fixCtx, CommandCtx(cmdScheme, cmdPath, cmdText, tableRow, tableCols, ignore))
			}

		} catch (Err err) {
			fixCtx.errs.add(err)
			fixCtx.skin.cmdErr(cmdUrl, cmdText, err)
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