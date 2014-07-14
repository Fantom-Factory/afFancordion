
** Contains meta information about a Condordion fixture.
const class FixtureMeta {
	
	** The fixture title. Taken from either the first heading in the specification or the fixture type name.
	const Str	title

	** The type of the fixture being run.
	const Type	fixtureType

	** Where the template originated from. Example, 'file://HelloWorldFixture.efan'. 
	const Uri	specificationLoc

	** The original efan template source string. Usually the fixture's doc comment.
	const Str	specificationSrc

	** Where the tests are run from. 
	const File	baseDir
	
	** The base dir of where the generated HTML result files are saved.
	const File	outputDir

	** When the fixture run was started
	const DateTime StartTime

	internal new make(|This|? in := null) { in?.call(this) }
}

class FixtureCtx {
	
	** The fixture being run.
	Obj				fixtureInstance

	** The concordion skin being used to render the result HTML
	ConcordionSkin	skin
	
	** The 'StrBuf' that the result HTML is printed to.
	StrBuf			renderBuf

	** A list of Errs encountered.
	Err[]			errs
	
	internal new make(|This|? in := null) { in?.call(this) }
}