
internal class CmdTable : Command {
	private static const Regex 			regexCol	:= "col\\[([0-9]+)\\]".toRegex
	private static const TableParser	tableParser	:= TableParser()

	override Void runCommand(FixtureCtx fixCtx, Uri cmdUrl, Str cmdText) {
		cols  := Int:Str[][:]
		lines := cmdText.splitLines.exclude |line->Bool| {
			i := line.index(":")
			if (i != null) {
				scheme := line[0..<i]
				matcher := regexCol.matcher(scheme)
				// assume non-matching lines are *not* commands
				if (matcher.find) {
					idx := matcher.group(1).toInt
					cmd := "\\+?col\\[${idx}\\]\\+?".toRegex.matcher(line).replaceFirst("").trim
					cols.getOrAdd(idx) { Str[,] }.add(cmd)
					return true
				}
			}
			return false
		}
		table := tableParser.parseTable(lines)
		
		commands := Commands(fixCtx.fancordionRunner.commands)
		
		skin := fixCtx.skin
		buff := fixCtx.renderBuf
		buff.add(skin.table)
		buff.add(skin.tr)
		table[0].each { buff.add(skin.th(it)) }
		buff.add(skin.trEnd)
		
		table.eachRange(1..-1) |row| {
			buff.add(skin.tr)
			row.each |col, i| {
				if (cols.containsKey(i)) {
					cols[i].each |cmd| {
						commands.doCmd(fixCtx, cmd.toUri, col)
					}
				} else
					buff.add(skin.td(col))				
			}
			buff.add(skin.trEnd)
		}
		buff.add(skin.tableEnd)
	}
	
}
