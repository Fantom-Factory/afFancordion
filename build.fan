using build

class Build : BuildPod {

	new make() {
		podName = "afFancordion"
		summary = "A tool for creating automated acceptance tests"
		version = Version("0.0.6")

		meta = [
			"proj.name"		: "Fancordion",	
			"tags"			: "testing",
			"repo.private"	: "false"
		]

		depends = [
			"sys 1.0",
			"concurrent 1.0",
			"compiler 1.0",
			"fandoc 1.0",
			
			// ---- Core ------------------------
			"afBeanUtils 1.0.2+",
			"afConcurrent 1.0.6+",
			"afPlastic 1.0.16+",			

			// ---- Test ------------------------
			"afBounce 1.0.16+",
			"afSizzle 1.0.0+"
		]

		srcDirs = [`test/`, `fan/`, `fan/public/`, `fan/internal/`, `fan/internal/commands/`]
		resDirs = [`test/`, `res/classicSkin/`]
	}
	
	override Void compile() {
		// remove test pods from final build
		testPods := "afBounce afSizzle".split
		depends = depends.exclude { testPods.contains(it.split.first) }
		super.compile
	}
}
