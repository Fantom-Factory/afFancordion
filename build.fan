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
			"fandoc 1.0",
			
			"afConcurrent 1.0.2+",
			"afPlastic 1.0.10+",
			"afIoc 1.6.0+",
			"afEfan 1.3.8+",
			
			"compiler 1.0"
		]


		srcDirs = [`test/`, `fan/`, `fan/public/`, `fan/internal/`]
		resDirs = [`doc/`]

		docApi = true
		docSrc = true
	}
}
