
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

	static Str cmdNotFound(Str cmd, Str cmdUrl) {
		"Could not find Command '${cmd}': ${cmdUrl}"
	}

	static Str cmdHasNullScheme(Str cmdUrl) {
		"Command URL does not specify a scheme: ${cmdUrl}"
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

	static Str cmdTable_tableNotFound(Str text) {
		"Could not find table syntax in:\n${text}"
	}

	static Str cmdTable_onlyOneRowCmdAllowed(Str cmd1, Str cmd2) {
		"Only one row command is allowed per table: row+${cmd1}, row+${cmd2}"
	}

	static Str cmdTable_onlyCmdPerColAllowed(Obj idx, Str cmd1, Str cmd2) {
		"Only one command per column is allowed per table: col[${idx}]+${cmd1}, col[${idx}]+${cmd2}"
	}

	static Str cmdTable_onlyOneVerifyRowsCmdAllowed(Str cmd1, Str cmd2) {
		"Only one verifyRows command is allowed per table: ${cmd1}, ${cmd2}"
	}

	static Str cmdTable_cantMixAndMatchCommands(Str cmd) {
		"VerifyRows command can not be used with any other table command: ${cmd}"
	}

	static Str cmdTable_expectingList(Obj? row) {
		"Expecting a List to verify rows in a 2D table: ${row}"
	}

	private static Str stripSys(Str str) {
		str.replace("sys::", "")
	}
}
