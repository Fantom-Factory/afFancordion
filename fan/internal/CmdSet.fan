using afBeanUtils

** The 'set' command sets a field of the fixture to the value of the link text. 
** The 'Str' is [coercered]`afBeanUtils::TypeCoercer` to the field's type.  
** 
** pre>
** ** The meaning of life is [42]`set:number`.
** @Fixture
** class ExampleFixture {
**   Int? number
** }
** <pre
** 
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
