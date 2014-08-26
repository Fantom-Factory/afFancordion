
** Place on a class to mark it as a Fancordion Fixture.
@FacetMeta { inherited = true }
facet class Fixture {

	** By default Fancordion uses the Fixture Type's doc comment as the specification.
	** If you wish to use an external file then use this attribute to explicitly set the location of the Fandoc specification. 
	**  
	** The URI may take several forms:
	**  - if fully qualified, the specification is resolved, e.g. 'fan://acmePod/specs/MyFixture.fandoc' or 'file:/etc/specs/MyFixture.fandoc'  
	**  - if relative, the specification is assumed to be on the file system, e.g. 'etc/specs/MyFixture.fandoc' 
	**  - if absolute, the specification is assumed to be a pod resource, e.g. '/etc/specs/MyFixture.fandoc'
	** 
	** If the URI is a directory, then the file name is taken to be the name of the fixture Type plus a '.fandoc' extension.
	const Uri? specification

	** If set to 'true' then should a command fail (throw an Err) then all following commands in the specification are ignored.
	** This assumes that should one command fail, it is not worth while running any others. 
	** 
	** If set to 'false' then all commands are executed, regardless of previous commands failing.
	** 
	** Defaults to 'true'.
	const Bool failFast	:= true
}
