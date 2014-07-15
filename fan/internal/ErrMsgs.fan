
internal const class ErrMsgs {

	static Str fixtureFacetNotFound(Type fixtureType) {
		stripSys("Could not find facet '@Fixture' on instance '${fixtureType.qname}'")
	}

	static Str cmdNotFound(Str cmd) {
		"Could not find Command '${cmd}'"
	}

	static Str verifyCmdNotFound(Str cmd) {
		"Could not find Verify command '${cmd}'"
	}

	static Str specFinder_couldNotFindSpec(Type fixtureType) {
		stripSys("Could not find a specification for fixture '${fixtureType.qname}'")
	}

	private static Str stripSys(Str str) {
		str.replace("sys::", "")
	}
}
