
** Implement to create your own Fancordion commands. 
** To use your own command in a specification, add it to the 'FancordionRunner':
** 
**   runner := FancordionRunner()
**   myCmd  := MyCommand()
**   runner.commands["mycmd"] = myCmd
** 
mixin Command {

	** If 'true' then this command can be ignored should a previous command fail.
	** 
	** Defaults to 'true'.
	virtual Bool canFailFast() { true }

	** Runs the command with the given URI and text. 
	abstract Void runCommand(FixtureCtx fixCtx, CommandCtx cmdCtx)

}
