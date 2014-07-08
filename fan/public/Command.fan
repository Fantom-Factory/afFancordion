
** Implement to create your own Concordion commands.
mixin Command {
	
	** Runs the command with the given URI and text. 
	** Return efan code to be inserted in the fixture. 
	abstract Str doCmd(Uri cmdUrl, Str cmdText)
	
}