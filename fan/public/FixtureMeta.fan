
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

	** The base directory of where the generated HTML result files are saved.
	const File	baseOutputDir

	** The directory where the generated HTML result file will be saved.
	** 
	** Defaults to '`%{baseOutputDir}/%{fixtureType.pod.name}/`' 
	const File	fixtureOutputDir

	** When the fixture run was started
	const DateTime StartTime

	internal new make(|This|? in := null) { in?.call(this) }
}

** Contains contextual information about a Condordion fixture.
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