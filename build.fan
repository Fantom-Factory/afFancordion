using build

class Build : BuildPod {

	new make() {
		podName = "afConcordion"
		summary = "Automated acceptance testing"
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
			
			"afConcurrent 1.0.2+",
			"afPlastic 1.0.11+",
			"afEfan 1.4.0+",
			
			
			// for testing
			"afBounce 1.0.1+",
			"build 1.0",
			"afSizzle 1.0.0+"
		]

		srcDirs = [`test/`, `fan/`, `fan/public/`, `fan/internal/`, `fan/internal/utils/`]
		resDirs = [`res/`]

		docApi = true
		docSrc = true
	}
	
	override Void compile() {
		depends.remove("afBounce 1.0.0+")
		depends.remove("afSizzle 1.0.0+")
	}
}
