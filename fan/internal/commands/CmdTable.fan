using afBeanUtils

internal class CmdTable : Command {
	private static const Regex 			regexCol	:= "col\\[([0-9n]+)\\]".toRegex
	private static const Regex 			regexRow	:= "row\\[([0-9n]+)\\]".toRegex
	private static const Regex 			regexReplce	:= "\\+?col\\[[0-9n]\\]\\+?".toRegex
	private static const TableParser	tableParser	:= TableParser()
				override Bool 			canFailFast := false
	
	** Meh, this class is messy and needs clean up... at least it works... kind of!
	override Void runCommand(FixtureCtx fixCtx, CommandCtx cmdCtx) {
		
		// limit the number of commands, i.e. only one cmd per col
		// that way, it makes skinning the table easier...
		// we don't have to blend 2 failures 1 pass into a single table cell!
		
		// ---- parse the commands --------------
		
		colNCmd			:= (Str?) null
		colCmds 		:= Obj:Str[:]
		rowCmd 			:= (Str?) null
		verifyRowsCmd	:= (Str?) null
		lines := cmdCtx.cmdText.splitLines.exclude |line->Bool| {
			i := line.index(":")
			if (i != null) {
				scheme := line[0..<i].trim	// real URI schemes cannot contain [] chars

				if (scheme.lower.startsWith("row+")) {
					if (rowCmd != null)
						throw Err(ErrMsgs.cmdTable_onlyOneRowCmdAllowed(rowCmd, line[4..-1]))
					rowCmd = line[4..-1]
					return true
				}

				if (scheme.lower.startsWith("verifyrows")) {
					if (verifyRowsCmd != null)
						throw Err(ErrMsgs.cmdTable_onlyOneVerifyRowsCmdAllowed(verifyRowsCmd, line))
					verifyRowsCmd = line
					return true
				}
				
				// assume non-matching lines are *not* commands
				matcher := regexCol.matcher(scheme)
				if (matcher.find) {
					cmd := regexReplce.matcher(line).replaceFirst("").trim
					col := matcher.group(1)
					idx := Int.fromStr(col, 10, false) == null ? col.upper : col.toInt
					if (colCmds.containsKey(idx))
						throw Err(ErrMsgs.cmdTable_onlyCmdPerColAllowed(idx, colCmds[idx], cmd))
					colCmds[idx] = cmd
					return true
				}
			}
			return false
		}
		table := tableParser.parseTable(lines)
		
		if (colCmds.containsKey("N") && colCmds.size > 1)
			throw Err(ErrMsgs.cmdTable_onlyCmdPerColAllowed("N", colCmds[colCmds.keys[0]], colCmds[colCmds.keys[1]]))
		if (verifyRowsCmd != null && (rowCmd != null || !colCmds.isEmpty))
			throw Err(ErrMsgs.cmdTable_cantMixAndMatchCommands(verifyRowsCmd))
		

		if (cmdCtx.ignore) {
			renderTable(fixCtx, table, "ignored")
			return
		}
		
		
		verifyRows := (Obj[]?) null
		if (verifyRowsCmd != null) {
			vrcScheme := verifyRowsCmd.split(':')[0]
			vrcPath	  := verifyRowsCmd[vrcScheme.size+1..-1]
			try verifyRows = (Obj[]) cmdCtx.getFromFixture(fixCtx.fixtureInstance, vrcPath)
			catch (Err err) {
				fixCtx.errs.add(err)
				fixCtx.skin.cmdErr(verifyRowsCmd, "", err)
				renderTable(fixCtx, table, "error")
				return
			}
		}

		
		commands := Commands(fixCtx.fancordionRunner.commands)
		
		skin := fixCtx.skin
		skin.table
		skin.tr
		table[0].each { skin.th(it) }
		skin.trEnd
		
		noOfCols := table[0].size
		table.eachRange(1..-1) |row, ri| {
			skin.tr
			trIdx := fixCtx.skin.renderBuf.size-1
			
			row.each |col, i| {
				if (colCmds.containsKey(i)) {
					commands.doCmd(fixCtx, colCmds[i], col, null)

				} else if (colCmds.containsKey("N")) {
					commands.doCmd(fixCtx, colCmds["N"].replace("#N", i.toStr), col, null)

				} else if (verifyRows != null) {
					// do 2D tables
					actualRow := verifyRows.getSafe(ri-1) ?: Obj#.emptyList
					if (noOfCols > 1 && actualRow isnot List)
						throw Err(ErrMsgs.cmdTable_expectingList(actualRow))
					actualCell := noOfCols == 1 ? actualRow : ((List) actualRow).getSafe(i)
					
					actual   := TypeCoercer().coerce(actualCell, Str?#) 
					expected := col 
					try {
						test := (fixCtx.fixtureInstance is Test) ? (Test) fixCtx.fixtureInstance : TestImpl()
						test.verifyEq(expected, actual)
						fixCtx.skin.cmdSuccess(actual)
			
					} catch (Err err) {
						fixCtx.errs.add(err)
						fixCtx.skin.cmdFailure(expected, actual)
					}

				} else
					skin.td(col)
			}
			
			// ---- do row commands ----
			if (rowCmd != null) {
				// create a fake skin so successful cmds aren't rendered
				tableSkin := TableSkinWrapper()
				rowFixCtx := FixtureCtx {
					it.fancordionRunner	= fixCtx.fancordionRunner
					it.fixtureInstance	= fixCtx.fixtureInstance
					it.skin				= tableSkin
					it.errs				= fixCtx.errs
				}
				
				// run the command
				commands.doCmd(rowFixCtx, rowCmd, row.toStr, row)
				
				// highlight the row with the appropriate class
				// TODO: this is bad, shouldn't pass the css class in, should let the skin decide
				if (tableSkin.error)
					fixCtx.skin.renderBuf.insert(trIdx, " class=\"error\"")
				else if (tableSkin.failure)
					fixCtx.skin.renderBuf.insert(trIdx, " class=\"failure\"")
				else if (tableSkin.ignored)
					fixCtx.skin.renderBuf.insert(trIdx, " class=\"ignored\"")
				else
					fixCtx.skin.renderBuf.insert(trIdx, " class=\"success\"")

				// render the errors and failures
				tableSkin.funcs.each { it.call(fixCtx.skin) }
			}
			
			skin.trEnd
		}
		
		// fail if the actual data has more rows than the table
		if (verifyRows != null && verifyRows.size > (table.size-1)) {
			verifyRows.eachRange(table.size-1..-1) |actualRow| {
				skin.tr
				noOfCols.times |i| {
					// do 2D tables
					if (noOfCols > 1 && actualRow isnot List)
						throw Err(ErrMsgs.cmdTable_expectingList(actualRow))
					actualCell := noOfCols == 1 ? actualRow : ((List) actualRow).getSafe(i)
					actual     := TypeCoercer().coerce(actualCell, Str?#) 
					fixCtx.skin.cmdFailure(Str.defVal, actual)				
				}
				skin.trEnd
			}
		}

		skin.tableEnd
	}
	
	
	private Void renderTable(FixtureCtx fixCtx, Str[][] table, Str css) {
		skin := fixCtx.skin
		buff := fixCtx.skin.renderBuf

		// TODO: this is bad, shouldn't pass the css class in, should let the skin decide
		buff.add(skin.table(css))
		buff.add(skin.tr)
		table[0].each { buff.add(skin.th(it)) }
		buff.add(skin.trEnd)
		
		noOfCols := table[0].size
		table.eachRange(1..-1) |row, ri| {
			buff.add(skin.tr)
			trIdx := buff.size-1
			
			row.each |col, i| {
				buff.add(skin.td(col))
			}
					
			buff.add(skin.trEnd)
		}
		
		buff.add(skin.tableEnd)		
	}
}

internal class TableSkinWrapper : FancordionSkin {
	override Uri[]	cssUrls		:= [,]
	override Uri[]	scriptUrls	:= [,]
	override StrBuf	renderBuf	:= StrBuf()
	
	|FancordionSkin|[] funcs	:= [,]
	Bool 			ignored		:= false
	Bool 			failure		:= false
	Bool 			error		:= false
	
	override This cmdIgnored(Str text) {
		ignored = true
		return this
	}

	override This cmdSuccess(Str text, Bool escape := true) {
		this
	}

	override This cmdFailure(Str expected, Obj? actual, Bool escape := true) {
		failure = true
		funcs.add(|FancordionSkin skin| { skin.cmdFailure(expected, actual, escape) })
		return this
	}

	override This cmdErr(Str cmdUrl, Str cmdText, Err err) {
		error = true
		funcs.add(|FancordionSkin skin| { skin.cmdErr(cmdUrl, cmdText, err) })
		return this
	}
}
