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
** Fields may also be set on nested objects using standard dot notation: 
** 
**   ** My name is [Forrest]`set:user.name`
** 
internal class CmdSet : Command {

	override Void runCommand(FixtureCtx fixCtx, CommandCtx cmdCtx) {
		// we can't call 'setOnFixture()' because we need to know what the field type is so we can 
		// coerce the value

		// can't set the field directly because that doesn't cater for nested properties, 
		// e.g. subject.difficulty
		
		// don't like using BeanProperties because (currently) it's not proper Fantom code.
		// e.g. setName(Steve) not setName("Steve") 
		// TODO: use BeanPropertyFactory().parse(property).set(instance, value)
		// and use own TypeCoercer that looks for fromCode().

		// FIXME: only use beanprops for simple props
		
		// FIXME: fandoc
		if (cmdCtx.cmdPath.all { it.isAlphaNum || it == '.' })
			BeanProperties.set(fixCtx.fixtureInstance, cmdCtx.cmdPath, cmdCtx.cmdText)
		else {
			fixCode := cmdCtx.applyVariables
			fanCode := "${fixCode} = ${cmdCtx.cmdText.toCode}"
			executeOnFixture(fixCtx.fixtureInstance, fanCode)
		}
		
		fixCtx.renderBuf.add(fixCtx.skin.cmdSuccess(cmdCtx.cmdText))
	}
}
