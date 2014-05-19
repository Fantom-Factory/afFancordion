
@NoDoc
mixin Command {
	
	abstract Void doCmd(OutStream out, Str cmd, Str param, Str text)

	protected Str escXml(Str text) {
		text.toXml
	}
	
}