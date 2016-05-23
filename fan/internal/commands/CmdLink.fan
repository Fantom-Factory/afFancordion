
** The 'link' command renders a standard HTML <a> tag. 
** It is added with the 'file', 'http', 'https' and 'mailto' schemes.   
** 
** pre>
** ** Be sure to check out [Fantom-Factory]`http://www.fantomfactory.org/`.
** @Fixture
** class ExampleFixture { }
** <pre
internal class CmdLink : Command {
	
	override Bool canFailFast	:= false
	
	override Void runCommand(FixtureCtx fixCtx, CommandCtx cmdCtx) {
		
		if (cmdCtx.cmdScheme == "link") {
			typeName := cmdCtx.cmdPath.endsWith("#") ? cmdCtx.cmdPath[0..<-1] : cmdCtx.cmdPath 			
			newType 
				:= (typeName.contains("::")) 
				? Type.find(typeName, false)
				: fixCtx.fixtureInstance.typeof.pod?.type(typeName, false)
			
			if (newType == null)
				throw Err(ErrMsgs.cmdRun_fixtureNotFound(typeName))

			fixCtx.skin.a(`${newType.name}.html`, cmdCtx.cmdText)

		} else {
			scheme := cmdCtx.cmdScheme.isEmpty ? "" : "${cmdCtx.cmdScheme}:"
			fixCtx.skin.a(`${scheme}${cmdCtx.cmdPath}`, cmdCtx.cmdText)
		}
	}
}
