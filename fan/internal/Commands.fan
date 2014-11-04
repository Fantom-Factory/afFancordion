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
			if (cmdUrl.toUri.scheme == null)
				throw CmdNotFoundErr(ErrMsgs.cmdHasNullScheme(cmdUrl), commands.keys)

			cmd := cmdUrl.toUri.scheme
			command := commands[cmd] ?: throw CmdNotFoundErr(ErrMsgs.cmdNotFound(cmd, cmdUrl), commands.keys)
			
			if (!fixCtx.errs.findAll { it isnot FailErr }.isEmpty && fixFacet.failFast && command.canFailFast)
				fixCtx.renderBuf.add(fixCtx.skin.cmdIgnored(cmdText))
			else
				command.runCommand(fixCtx, CommandCtx(cmdUrl.toUri, cmdText, tableCols), cmdUrl.toUri, cmdText)

		} catch (Err err) {
			fixCtx.errs.add(err)
			fixCtx.renderBuf.add(fixCtx.skin.cmdErr(cmdUrl, cmdText, err))
		}
	}
}

** Contains contextual information about a Fancordion command.
const class CommandCtx {
	** The URI portion of the command:
	** 
	**   [text]`uri`
	const Uri		cmdUrl
	
	** The text portion of the command:
	** 
	**   [text]`uri`
	** 
	** For table column commands this is the column text.
	const Str		cmdText
	
	** The columns that make up a table row. Only available in table row commands.
	const Str[]?	tableCols

	internal new make(Uri cmdUrl, Str cmdText, Str[]? tableCols) {
		this.cmdUrl		= cmdUrl
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
	Str applyVariables(Str text) {
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