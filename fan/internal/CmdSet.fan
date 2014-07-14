using afBeanUtils

internal class CmdSet : Command {

	override Void doCmd(FixtureCtx fixCtx, Uri cmdUrl, Str cmdText) {
		try {
			fieldName	:= cmdUrl.pathStr
			field       := fixCtx.fixtureInstance.typeof.field(fieldName, true)
			fieldValue  := TypeCoercer().coerce(cmdText, field.type)
			field.set(fixCtx.fixtureInstance, fieldValue)

			fixCtx.renderBuf.add(fixCtx.skin.cmdSuccess(cmdText))

		} catch (Err err) {
			fixCtx.errs.add(err)
			fixCtx.renderBuf.add(fixCtx.skin.cmdErr(cmdUrl, cmdText, err))
		}
	}
}
