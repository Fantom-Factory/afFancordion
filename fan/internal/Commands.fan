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

** Contains contextual information about a Fancordion command.
const class CommandCtx {

	** The *scheme* portion of the command URI:
	** 
	**   [text]`scheme:path`
	const Str		cmdScheme

	** The *path* portion of the command URI (minus the scheme):
	** 
	**   [text]`scheme:path`
	const Str		cmdPath
	
	** The *text* portion of the command:
	** 
	**   [text]`scheme:path`
	** 
	** For table column commands this is the column text.
	const Str		cmdText
	
	** The columns that make up a table row. Only available in table row commands.
	const Str[]?	tableCols

	internal new make(Str cmdScheme, Str cmdPath, Str cmdText, Str[]? tableCols) {
		this.cmdScheme	= cmdScheme
		this.cmdPath	= cmdPath
		this.cmdText	= cmdText
		this.tableCols	= tableCols
	}
	
	** Applies Fancordion variables to the given str. 
	** Specifically it replaces portions of the string with:
	** 
	**  - '#TEXT    -> cmdText.toCode'
	**  - '#COLS    -> tableCols.toCode'
	**  - '#COL[0]  -> tableCols[0].toCode'
	**  - '#COL[1]  -> tableCols[1].toCode'
	**  - '#COL[n]  -> tableCols[n].toCode'
	**  - '#FIXTURE -> "fixture"'
	Str applyVariables(Str text := cmdPath) {
		text = text.replace("#TEXT", cmdText.toCode)
		tableCols?.each |col, i| {
			text = text.replace("#COL[${i}]", tableCols[i].toCode)
		}
		if (tableCols != null)
			text = text.replace("#COLS", tableCols.toCode)
		text = text.replace("#FIXTURE", "fixture")
		return text
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