using afBeanUtils

internal class CmdTable : Command {
	private static const Regex 			regexCol	:= "col\\[([0-9]+)\\]".toRegex
	private static const TableParser	tableParser	:= TableParser()

	override Void runCommand(FixtureCtx fixCtx, Uri cmdUrl, Str cmdText) {
		verifyRowsCmd := (Str?) null
		cols  := Int:Str[][:]
		lines := cmdText.splitLines.exclude |line->Bool| {
			i := line.index(":")
			if (i != null) {
				scheme := line[0..<i].trim

				if (scheme.lower.startsWith("verifyrows")) {
					verifyRowsCmd = line
					return true
				}
				
				// assume non-matching lines are *not* commands
				matcher := regexCol.matcher(scheme)
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
		
		
		rows := (Obj[]?) null
		if (verifyRowsCmd != null)
			rows = (Obj[]) getFromFixture(fixCtx.fixtureInstance, pathStr(verifyRowsCmd.toUri))

		
		commands := Commands(fixCtx.fancordionRunner.commands)
		
		skin := fixCtx.skin
		buff := fixCtx.renderBuf
		buff.add(skin.table)
		buff.add(skin.tr)
		table[0].each { buff.add(skin.th(it)) }
		buff.add(skin.trEnd)
		
		// TODO: I should enable BOTH col commands and verify rows on the same table.
		// The skin will probably need to be updated to reflect the new code
		table.eachRange(1..-1) |row, ri| {
			buff.add(skin.tr)
			row.each |col, i| {
				if (cols.containsKey(i)) {
					cols[i].each |cmd| {
						commands.doCmd(fixCtx, cmd.toUri, col)
					}
				} else if (rows != null) {
					// TODO: verifyRows should work on 2D tables
					actual   := TypeCoercer().coerce(rows.getSafe(ri-1), Str?#) 
					expected := col 
					try {
						test := (fixCtx.fixtureInstance is Test) ? (Test) fixCtx.fixtureInstance : TestImpl()
						test.verifyEq(expected, actual)
						fixCtx.renderBuf.add(fixCtx.skin.cmdSuccess(actual))
			
					} catch (Err err) {
						fixCtx.errs.add(err)
						fixCtx.renderBuf.add(fixCtx.skin.cmdFailure(expected, actual))
					}
				} else
					buff.add(skin.td(col))
			}
			buff.add(skin.trEnd)
		}
		
		if (rows != null && rows.size > (table.size-1)) {
			// TODO: verifyRows should work on 2D tables
			rows.eachRange(table.size-1..-1) |row| {
				buff.add(skin.tr)
				fixCtx.renderBuf.add(fixCtx.skin.cmdFailure(Str.defVal, row))				
				buff.add(skin.trEnd)
			}
		}

		buff.add(skin.tableEnd)
	}
}
