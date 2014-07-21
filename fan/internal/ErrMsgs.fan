
internal const class ErrMsgs {

	static Str urlMustBePathOnly(Str type, Uri url, Uri example) {
		"${type} URL `${url}` must ONLY be a path. e.g. `${example}`"
	}

	static Str urlMustNotStartWithSlash(Str type, Uri url, Uri example) {
		"${type} URL `${url}` must NOT start with a slash. e.g. `${example}`"
	}

	static Str urlMustNotEndWithSlash(Str type, Uri url, Uri example) {
		"${type} URL `${url}` must NOT end with a slash. e.g. `${example}`"
	}

	static Str fixtureFacetNotFound(Type fixtureType) {
		stripSys("Could not find facet '@Fixture' on instance '${fixtureType.qname}'")
	}

	static Str cmdNotFound(Str cmd, Uri cmdUrl) {
		"Could not find Command '${cmd}': ${cmdUrl}"
	}

	static Str verifyCmdNotFound(Str cmd) {
		"Could not find Verify command '${cmd}'"
	}

	static Str specFinder_couldNotFindSpec(Type fixtureType) {
		stripSys("Could not find a specification for fixture '${fixtureType.qname}'")
	}

	static Str specFinder_specNotFile(Uri specLoc, Type fixtureType, Type specType) {
		"Template Uri `${specLoc}` for ${fixtureType.qname} does not resolve to a file : ${specType.qname}"
	}

	static Str specFinder_specNotFound(Uri specLoc, Type fixtureType) {
		stripSys("Template Uri `${specLoc}` for ${fixtureType.qname} could not be resolved!")
	}

	static Str cmdTest_fixtureNotFound(Str fixtureType) {
		"Could not find Fixture '${fixtureType}'"
	}

	private static Str stripSys(Str str) {
		str.replace("sys::", "")
	}
}
