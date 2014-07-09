
** Place on a class to mark it as a Concordion Fixture.
@FacetMeta { inherited = true }
facet class Fixture {

//	** By default Concordion uses the Type's doc comment as the specification.
//	** If you wish to use an external file then use this to explicitly set the location of the Concordion fandoc specification. 
//	**  
//	** The URI may take several forms:
//	**  - if fully qualified, the specification is resolved, e.g. 'fan://acmePod/templates/Notice.efan' 
//	**  - if relative, the specification is assumed to be on the file system, e.g. 'etc/templates/Notice.efan' 
//	**  - if absolute, the specification is assumed to be a pod resource, e.g. '/templates/Notice.efan'
//	const Uri? specification
}
