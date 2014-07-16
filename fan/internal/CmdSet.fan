using afBeanUtils

internal class CmdSet : Command {

	override Void doCmd(FixtureCtx fixCtx, Uri cmdUrl, Str cmdText) {
		fieldName	:= cmdUrl.pathStr
		field       := fixCtx.fixtureInstance.typeof.field(fieldName, true)
		fieldValue  := TypeCoercer().coerce(cmdText, field.type)
		field.set(fixCtx.fixtureInstance, fieldValue)

		fixCtx.renderBuf.add(fixCtx.skin.cmdSuccess(cmdText))
	}
}
