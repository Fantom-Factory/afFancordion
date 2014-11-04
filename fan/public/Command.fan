using afPlastic

** Implement to create your own Fancordion commands. 
** To use your own command in a specification, just add it to the 'FancordionRunner':
** 
**   runner := FancordionRunner()
**   myCmd  := MyCommand()
**   runner.commands["mycmd"] = myCmd
** 
mixin Command {
	private static const PlasticCompiler compiler	:= PlasticCompiler()

	** If 'true' then this command can be ignored should a previous command fail.
	** 
	** Defaults to 'true'.
	virtual Bool canFailFast() { true }

	** Runs the command with the given URI and text. 
	abstract Void runCommand(FixtureCtx fixCtx, CommandCtx cmdCtx)
	
	** Helper method that executes the given code against the fixture instance. Example:
	** 
	**   executeOnFixture(fixture, "toStr()") --> fixture.toStr()
	Void executeOnFixture(Obj fixture, Str code) {
		model := PlasticClassModel("FixtureExecutor", false).extend(FixtureExecutor#)
		model.overrideMethod(FixtureExecutor#executeOn, "fixture := (${fixture.typeof.qname}) obj;\nfixture.${code}")
		help := (FixtureExecutor) compiler.compileModel(model).make
		help.executeOn(fixture)
	}	

	** Helper method that executes the given code on the fixture instance and returns a value. Example:
	** 
	**   getFromFixture(fixture, "toStr()")  --> fixture.toStr()
	Obj? getFromFixture(Obj fixture, Str code) {
		model := PlasticClassModel("FixtureExecutor", false).extend(FixtureExecutor#)
		model.overrideMethod(FixtureExecutor#getFrom, "fixture := (${fixture.typeof.qname}) obj;\nreturn fixture.${code}")
		help := (FixtureExecutor) compiler.compileModel(model).make
		return help.getFrom(fixture)
	}	
}

@NoDoc
abstract class FixtureExecutor {
	virtual Void executeOn(Obj obj) { }
	virtual Obj? getFrom  (Obj obj) { null }
}