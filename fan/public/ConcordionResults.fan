
class ConcordionResults {
	
	** The resulting HTML
	const Str result
	
	** The resulting HTML file.
	const File resultFile
	
	const Err[] errors

	internal new make(|This|? in := null) { in?.call(this) }
	
}
