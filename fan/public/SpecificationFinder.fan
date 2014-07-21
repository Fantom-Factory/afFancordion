using compiler

** Implement to create strategies for finding and reading Fandoc specifications from a given type.
@NoDoc	// Don't overwhelm the masses
mixin SpecificationFinder {

	** Returns the specification for the given fixture, or 'null' if it could not be found. 
	abstract SpecificationMeta? findSpecification(Type fixtureType)
	
}

@NoDoc	// Don't overwhelm the masses
const class SpecificationMeta {
	const Type	fixtureType
	const Str	specificationSrc
	const Uri	specificationLoc
	
	new make(|This| in) { in(this) }
}
