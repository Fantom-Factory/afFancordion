
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