
** Contains meta information about a Fancordion fixture.
const class FixtureMeta {
	
	** The fixture title. Taken from either the first heading in the specification or the fixture type name.
	const Str	title

	** The type of the fixture being run.
	const Type	fixtureType

	** Where the template originated from. Example, 'file://HelloWorldFixture.efan'. 
	const Uri	specificationLoc

	** The original efan template source string. Usually the fixture's doc comment.
	const Str	specificationSrc

	** The base directory of where the generated HTML result files are saved.
	const File	baseOutputDir

	** The file that the generated HTML result file will be saved as.
	const File	resultFile

	** When the fixture run was started
	const DateTime StartTime

	@NoDoc
	new make(|This|? in := null) { in?.call(this) }
}

** Contains contextual information about a Fancordion fixture.
class FixtureCtx {
	
	** The current runner.
	FancordionRunner	fancordionRunner

	** The fixture being run.
	Obj				fixtureInstance

	** The fancordion skin being used to render the result HTML
	FancordionSkin	skin

	** A list of Errs encountered, passed to 'FixtureResult' for reporting.
	Err[]			errs
	
	@NoDoc
	new make(|This|? in := null) { in?.call(this) }
}