using build
using compiler

class Build : BuildPod {

	new make() {
		podName = "afFancordion"
		summary = "A tool for creating automated acceptance tests and specification documents"
		version = Version("1.0.4")

		meta = [
			"proj.name"		: "Fancordion",	
			"repo.tags"		: "testing",
			"repo.public"	: "true"
		]

		depends = [
			"sys        1.0",
			"concurrent 1.0",
			"compiler   1.0",
			"fandoc     1.0",

			// ---- Core ------------------------
			"afBeanUtils  1.0.4  - 1.0",
			"afConcurrent 1.0.6  - 1.0",
			"afPlastic    1.0.16 - 1.0",			

			// ---- Test ------------------------
			"afBounce     1.0.18 - 1.0",
			"afSizzle     1.0.2  - 1.0"
		]

		srcDirs = [`test/`, `test/cmd-verifyErrType/`, `test/cmd-verifyErrMsg/`, `test/cmd-verify/`, `test/cmd-table/`, `test/cmd-set/`, `test/cmd-run/`, `fan/`, `fan/public/`, `fan/internal/`, `fan/internal/commands/`]
		resDirs = [`doc/`, `test/`, `res/classicSkin/`]
	}
	
	override Void compile() {
		// remove test pods from final build
		testPods := "afBounce afSizzle".split
		depends = depends.exclude { testPods.contains(it.split.first) }
		super.compile
	}
	
	** see http://fantom.org/forum/topic/2283
	override Void onCompileFan(CompilerInput ci) {
		ci.docTests = true
	}
}
