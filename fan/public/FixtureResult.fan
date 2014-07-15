
** Contains the result of a Concordion fixture run.
class FixtureResult {
	
	** Meta information about the fixture.
	const FixtureMeta fixtureMeta

	** The generated result (X)HTML.
	const Str resultHtml
	
	** The (X)HTML result file.
	const File resultFile
	
	** List of (any) Errs encountered (includes failures) during the fixture run.
	const Err[] errors
	
	// FIXME: duration and rendertimestamp

	internal new make(|This|? in := null) { in?.call(this) }
	
}
