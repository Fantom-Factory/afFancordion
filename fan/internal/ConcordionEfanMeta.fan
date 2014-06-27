
internal const class ConcordionEfanMeta {
	
	** The test title
	const Str title

	** The 'Type' of the compiled efan template.
	const Type type

	** The generated fantom code of the efan template (for the inquisitive).
	const Str typeSrc

	** Where the template originated from. Example, 'file://layout.efan'. 
	const Uri templateLoc

	** The original efan template source string.
	const Str templateSrc

	internal new make(|This|? in := null) { in?.call(this) }

}
