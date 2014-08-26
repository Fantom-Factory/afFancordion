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

		// can't set the field directly because that doesn't cater for nested properties, 
		// e.g. subject.difficulty
		
		// don't like using BeanProperties because (currently) it's not proper Fantom code.
		// e.g. setName(Steve) not setName("Steve") 
		// TODO: use BeanPropertyFactory().parse(property).set(instance, value)
		// and use own TypeCoercer that looks for fromCode().
		BeanProperties.set(fixCtx.fixtureInstance, pathStr(cmdUrl), cmdText)
		
		fixCtx.renderBuf.add(fixCtx.skin.cmdSuccess(cmdText))
	}
}
