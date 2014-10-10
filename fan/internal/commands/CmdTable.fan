using afBeanUtils

internal class CmdTable : Command {
	private static const Regex 			regexCol	:= "col\\[([0-9]+)\\]".toRegex
	private static const Regex 			regexRow	:= "row\\[([0-9]+)\\]".toRegex
	private static const TableParser	tableParser	:= TableParser()

	override Void runCommand(FixtureCtx fixCtx, CommandCtx cmdCtx, Uri cmdUrl, Str cmdText) {
		verifyRowsCmd	:= (Str?) null
		colCmds 		:= Int:Str[][:]
		rowCmds 		:= Str[,]
		lines := cmdText.splitLines.exclude |line->Bool| {
			i := line.index(":")
			if (i != null) {
				scheme := line[0..<i].trim	// real URI schemes cannot contain [] chars

				if (scheme.lower.startsWith("row+")) {
					rowCmds.add(line[4..-1])
					return true
				}

				if (scheme.lower.startsWith("verifyrows")) {
					verifyRowsCmd = line
					return true
				}
				
				// assume non-matching lines are *not* commands
				matcher := regexCol.matcher(scheme)
				if (matcher.find) {
					idx := matcher.group(1).toInt
					cmd := "\\+?col\\[${idx}\\]\\+?".toRegex.matcher(line).replaceFirst("").trim
					colCmds.getOrAdd(idx) { Str[,] }.add(cmd)
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
			trIdx := buff.size-1
			
			row.each |col, i| {
				if (colCmds.containsKey(i)) {
					colCmds[i].each |cmd| {
						commands.doCmd(fixCtx, cmd.toUri, col, null)
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
			
			// ---- do row commands ----
			if (!rowCmds.isEmpty) {
				// create a fake skin so successful cmds aren't rendered
				tableSkin := TableSkinWrapper()
				rowFixCtx := FixtureCtx {
					it.fancordionRunner	= fixCtx.fancordionRunner
					it.fixtureInstance	= fixCtx.fixtureInstance
					it.skin				= tableSkin
					it.renderBuf		= fixCtx.renderBuf
					it.errs				= fixCtx.errs
				}
				
				// run the commands
				rowCmds.each |rowCmd| {
					commands.doCmd(rowFixCtx, rowCmd.toUri, row.toStr, row)
				}
				
				// highlight the row with the appropriate class
				if (tableSkin.error)
					buff.insert(trIdx, " class=\"error\"")
				else if (tableSkin.failure)
					buff.insert(trIdx, " class=\"failure\"")
				else if (tableSkin.ignored)
					buff.insert(trIdx, " class=\"ignored\"")
				else
					buff.insert(trIdx, " class=\"success\"")

				// render the errors and failures
				tableSkin.funcs.each { fixCtx.renderBuf.add(it.call(fixCtx.skin)) }
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

internal class TableSkinWrapper : FancordionSkin {
	override Uri[]	cssUrls		:= [,]
	override Uri[]	scriptUrls	:= [,]
	
	|FancordionSkin->Str|[] funcs	:= [,]
	Bool 			ignored		:= false
	Bool 			failure		:= false
	Bool 			error		:= false
	
	override Str cmdIgnored(Str text) {
		ignored = true
		return Str.defVal
	}

	override Str cmdSuccess(Str text, Bool escape := true) {
		Str.defVal
	}

	override Str cmdFailure(Str expected, Obj? actual, Bool escape := true) {
		failure = true
		funcs.add(|FancordionSkin skin->Str| { skin.cmdFailure(expected, actual, escape) })
		return Str.defVal
	}

	override Str cmdErr(Uri cmdUrl, Str cmdText, Err err) {
		error = true
		funcs.add(|FancordionSkin skin->Str| { skin.cmdErr(cmdUrl, cmdText, err) })
		return Str.defVal
	}
}
