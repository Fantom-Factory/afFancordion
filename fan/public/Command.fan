using afPlastic

** Implement to create your own Concordion commands.
mixin Command {
	private static const PlasticCompiler compiler	:= PlasticCompiler()

	** Runs the command with the given URI and text. 
	abstract Void runCommand(FixtureCtx fixCtx, Uri cmdUrl, Str cmdText)
	
	** Helper method that executes the given code on the fixture instance. Example:
	** 
	**   executeOnFixture(fixture, "toStr()")
	Void executeOnFixture(Obj fixture, Str code) {
		model := PlasticClassModel("FixtureExecutor", false).extend(FixtureExecutor#)
		model.overrideMethod(FixtureExecutor#executeOn, "((${fixture.typeof.qname}) fixture).${code}")
		help := (FixtureExecutor) compiler.compileModel(model).make
		help.executeOn(fixture)
	}	

	** Helper method that executes the given code on the fixture instance and returns a value. Example:
	** 
	**   getFromFixture(fixture, "toStr()")
	Obj? getFromFixture(Obj fixture, Str code) {
		model := PlasticClassModel("FixtureExecutor", false).extend(FixtureExecutor#)
		model.overrideMethod(FixtureExecutor#getFrom, "((${fixture.typeof.qname}) fixture).${code}")
		help := (FixtureExecutor) compiler.compileModel(model).make
		return help.getFrom(fixture)
	}	
}

@NoDoc
abstract class FixtureExecutor {
	virtual Void executeOn(Obj fixture) { }
	virtual Obj? getFrom  (Obj fixture) { null }
}