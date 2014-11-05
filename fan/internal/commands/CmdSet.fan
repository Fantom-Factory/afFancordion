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
		// We can't call 'setOnFixture()' because we need to know what the field type is so we can 
		// coerce the value

		// We can't set the field directly because that doesn't cater for nested properties, 
		// e.g. subject.difficulty
		
		// can't use BeanProperties for everything because it's not proper Fantom code.
		// e.g. setName(Steve) not setName("Steve")
		
		// So...
		// Use BeanProperties for simple dot separated expressions for the implicit casting, and 
		// fantom code for everything else
		
		simpleExpression := cmdCtx.cmdPath.all |char, i| {
			// allow dude() but not dude(something)
			char.isAlphaNum || char == '.' || (char == '(' && cmdCtx.cmdPath.getSafe(i+1) == ')')
		}

		if (simpleExpression)
			BeanProperties.set(fixCtx.fixtureInstance, cmdCtx.cmdPath, cmdCtx.cmdText)
		else {
			fixCode := cmdCtx.applyVariables
			fanCode := "${fixCode} = ${cmdCtx.cmdText.toCode}"
			cmdCtx.executeOnFixture(fixCtx.fixtureInstance, fanCode)
		}
		
		fixCtx.renderBuf.add(fixCtx.skin.cmdSuccess(cmdCtx.cmdText))
	}
}
