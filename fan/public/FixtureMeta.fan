
** Contains meta information about a Condordion fixture.
const class FixtureMeta {
	
	** The fixture title. Taken from either the first heading in the template or the fixture type name.
	const Str	title

	** The 'Type' of the compiled efan template.
	const Type	fixtureType

	** The generated Fantom code of the efan template (for the inquisitive).
	const Str	fixtureSrc

	** Where the template originated from. Example, 'file://HelloWorldFixture.efan'. 
	const Uri	templateLoc

	** The original efan template source string. Usually the fixture's doc comment.
	const Str	templateSrc

	** Where the tests are run from. 
	const File	baseDir
	
	** The base dir of where the generated HTML result files are saved.
	const File	outputDir

	** Where the generated HTML result file will be saved.
	const File	resultFile

	** When the fixture run was started
	const DateTime StartTime

	internal new make(|This|? in := null) { in?.call(this) }

}
