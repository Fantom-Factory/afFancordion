using build
using compiler

class Build : BuildPod {

	new make() {
		podName = "afFancordion"
		summary = "A tool for creating automated acceptance tests and specification documents"
		version = Version("1.1.2")

		meta = [
			"proj.name"		: "Fancordion",	
			"repo.tags"		: "testing",
			"repo.public"	: "true"
		]

		depends = [
			"sys        1.0.68 - 1.0",
			"concurrent 1.0.68 - 1.0",
			"compiler   1.0.68 - 1.0",	// for parsing doc comments from src files
			"fandoc     1.0.68 - 1.0",

			// ---- Core ------------------------
			"afBeanUtils  1.0.8 - 1.0",
			"afPlastic    1.1.0 - 1.1",			

			// ---- Test ------------------------
			"afBounce     1.1.0 - 1.1",
			"afSizzle     1.0.2 - 1.0"
		]

		srcDirs = [`fan/`, `fan/internal/`, `fan/internal/commands/`, `fan/public/`, `test/`, `test/cmd-run/`, `test/cmd-set/`, `test/cmd-table/`, `test/cmd-verify/`, `test/cmd-verifyErrMsg/`, `test/cmd-verifyErrType/`]
		resDirs = [`doc/`, `test/`, `res/classicSkin/`]
		
		meta["afBuild.testPods"]	= "afBounce afSizzle"
	}
	
	** see http://fantom.org/forum/topic/2283
	override Void onCompileFan(CompilerInput ci) {
		ci.docTests = true
	}
}
