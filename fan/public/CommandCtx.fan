using afPlastic

** Contains contextual information about a Fancordion command.
const class CommandCtx {
	private static const PlasticCompiler compiler	:= PlasticCompiler()

	** The command URI.
	const Str		cmdUri

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
	
	** Is set to 'true' if there has been previous errors in the fixture and this command should be ignored.
	const Bool		ignore

	internal new make(Str cmdScheme, Str cmdPath, Str cmdText, Str[]? tableCols, Bool ignore) {
		this.cmdUri		= "${cmdScheme}:${cmdPath}"
		this.cmdScheme	= cmdScheme
		this.cmdPath	= cmdPath
		this.cmdText	= cmdText
		this.tableCols	= tableCols
		this.ignore		= ignore
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
	
	** Executes the given code against the fixture instance. Example:
	** 
	**   executeOnFixture(fixture, "echo()") --> fixture.echo()
	Void executeOnFixture(Obj fixture, Str code) {
		model := PlasticClassModel("FixtureExecutor", false).extend(FixtureExecutor#)
		body  := isSlotty(fixture, code)
				? "fixture := (${fixture.typeof.qname}) obj;\nfixture.${code}"
				: "fixture := (${fixture.typeof.qname}) obj;\n${code}"
		model.overrideMethod(FixtureExecutor#executeOn, body)
		if (fixture.typeof.pod != null)
			model.usingPod(fixture.typeof.pod)
		help := (FixtureExecutor) compiler.compileModel(model).make
		help.executeOn(fixture)
	}	

	** Executes the given code on the fixture instance and returns a value. Example:
	** 
	**   getFromFixture(fixture, "toStr()")  --> return fixture.toStr()
	Obj? getFromFixture(Obj fixture, Str code) {
		model := PlasticClassModel("FixtureExecutor", false).extend(FixtureExecutor#)
		body  := isSlotty(fixture, code)
				? "fixture := (${fixture.typeof.qname}) obj;\nreturn fixture.${code}"
				: "fixture := (${fixture.typeof.qname}) obj;\nreturn ${code}"
		model.overrideMethod(FixtureExecutor#getFrom, body)
		if (fixture.typeof.pod != null)
			model.usingPod(fixture.typeof.pod)
		help := (FixtureExecutor) compiler.compileModel(model).make
		return help.getFrom(fixture)
	}
	
	internal static Bool isSlotty(Obj fixture, Str code) {
		slotName := ""
		code.chars.eachWhile |char->Bool?| {
			if (char.isAlphaNum || char == ':') {
				slotName += char.toChar
				return null
			}
			return true
		}
		if (slotName.contains("::"))
			return false
		return fixture.typeof.slot(slotName, false) != null
	}
}

@NoDoc
abstract class FixtureExecutor {
	virtual Void executeOn(Obj obj) { }
	virtual Obj? getFrom  (Obj obj) { null }
}
