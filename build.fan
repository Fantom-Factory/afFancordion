using build

class Build : BuildPod {

	new make() {
		podName = "afConcordion"
		summary = "Transform boring unit tests into beautiful specification documents"
		version = Version("0.0.1")

		meta = [
			"proj.name"		: "Concordion",	
			"repo.private"	: "true"
		]

		depends = [
			"sys 1.0",
			"concurrent 1.0",
			"compiler 1.0",
			"fandoc 1.0",
			
			// ---- Core ------------------------
			"afBeanUtils 1.0.0+",
			"afConcurrent 1.0.6+",
			"afPlastic 1.0.14+",
			
			
			// ---- Test ------------------------
			"afBounce 1.0.4+",
			"afSizzle 1.0.0+",
			"build 1.0"
		]

		srcDirs = [`test/`, `fan/`, `fan/public/`, `fan/internal/`]
		resDirs = [`test/`, `res/classicSkin/`]
	}
	
	override Void compile() {
		// remove test pods from final build
		testPods := "afBounce afSizzle build".split
		depends = depends.exclude { testPods.contains(it.split.first) }
		super.compile
	}
}
