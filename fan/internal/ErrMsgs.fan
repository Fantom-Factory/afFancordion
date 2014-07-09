
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

	private static Str stripSys(Str str) {
		str.replace("sys::", "")
	}
}
