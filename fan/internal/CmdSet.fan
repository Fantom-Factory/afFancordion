using afBeanUtils

internal class CmdSet : Command {

	override Void runCommand(FixtureCtx fixCtx, Uri cmdUrl, Str cmdText) {
		// we can't call 'setOnFixture()' because we need to know what the field type is so we can 
		// coerce the value
		
		fieldName	:= cmdUrl.pathStr
		field       := fixCtx.fixtureInstance.typeof.field(fieldName, true)
		fieldValue  := TypeCoercer().coerce(cmdText, field.type)
		field.set(fixCtx.fixtureInstance, fieldValue)

		fixCtx.renderBuf.add(fixCtx.skin.cmdSuccess(cmdText))
	}
}
