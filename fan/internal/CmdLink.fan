
internal class CmdLink : Command {
	
	override Str doCmd(Uri cmdUrl, Str cmdText) {
		"""<a href="${cmdUrl}">${cmdText}</a>"""
	}
}
