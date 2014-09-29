
internal class CmdTable : Command {
	private static const Regex 			regexCol	:= "col\\[([0-9]+)\\]".toRegex
	private static const TableParser	tableParser	:= TableParser()

	override Void runCommand(FixtureCtx fixCtx, Uri cmdUrl, Str cmdText) {
		cmds := Str[,]
		cols := Int:Str[][:]

		lines := cmdText.splitLines.exclude |line->Bool| {
			i := line.index(":")
			if (i != null) {
				scheme := line[0..<i]
				matcher := regexCol.matcher(scheme)
				if (matcher.find) {
					idx := matcher.group(1).toInt
					cmd := "\\+?col\\[${idx}\\]\\+?".toRegex.matcher(line).replaceFirst("")
					cols.getOrAdd(idx) { Str[,] }.add(cmd)
					return true
				} else {
					cmds.add(line)
					return true
				}
			}
			return false
		}

		table := tableParser.parseTable(lines)
		
		Env.cur.err.printLine(lines.join("\n"))
		
		commands := Commands(fixCtx.fancordionRunner.commands)
	}
	
}
