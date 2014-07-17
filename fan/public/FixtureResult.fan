
** Contains the result of a Concordion fixture run.
const class FixtureResult {
	
	** Meta information about the fixture.
	const FixtureMeta fixtureMeta

	** The generated result (X)HTML.
	const Str resultHtml
	
	** The (X)HTML result file.
	const File resultFile
	
	** List of (any) Errs encountered (includes failures) during the fixture run.
	const Err[] errors
	
	** The timestamp when this result was created.
	const DateTime	timestamp
	
	** How long the test took.
	const Duration duration

	internal new make(|This|? in := null) { in?.call(this) }
	
}
