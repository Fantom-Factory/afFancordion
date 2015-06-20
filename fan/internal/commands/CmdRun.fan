
** The 'run' command runs another Fancordion fixture and prints an appropriate success / failure link to it.
** 
** The command path must be the name of the Fixture type to run. The fixture type may be qualified.
** 
** Use 'run' commands to create a specification containing a list of all acceptance tests for a feature, in a similar way you would use a test suite.
** 
** You could even nest specifications to form a hierarchical index, with results aggregated to display a single green / red / gray result.     
** 
** pre>
** ** Questions:
** ** - [Why is the sky blue?]`run:BlueSkyFixture#`.
** @Fixture
** class ExampleFixture { }
** <pre
internal class CmdRun : Command {

	override Bool canFailFast	:= false

	override Void runCommand(FixtureCtx fixCtx, CommandCtx cmdCtx) {
		typeName := cmdCtx.cmdPath.endsWith("#") ? cmdCtx.cmdPath[0..<-1] : cmdCtx.cmdPath 
		
		newType 
			:= (typeName.contains("::")) 
			? Type.find(typeName, false)
			: fixCtx.fixtureInstance.typeof.pod?.type(typeName, false)

		if (newType == null) {
			// TODO: scan file system for type and load fixture as script
			// but currently our runner is only launched via fant which only runs from a pod 
			// actually - that's a lie, fant can run scripts too! - http://fantom.org/doc/docTools/Fant.html#running
			throw Err(ErrMsgs.cmdRun_fixtureNotFound(typeName))
		}
	
		// ensure it's a fixture so we have an output HTML file to link to
		// we could link to unit tests - but then we'd need to make it look pretty.
		// save it for the next project - or a plugin!
		if (!newType.hasFacet(Fixture#))
			throw Err(ErrMsgs.fixtureFacetNotFound(newType))

		if (newType == fixCtx.fixtureInstance.typeof)
			throw Err(ErrMsgs.cmdRun_stoopidRecursion(newType))			
		
		try {
			if (newType.fits(Test#)) {
				// if only fant was written in Fantom!
				testMethods := newType.methods.findAll { it.name.startsWith("test") && it.params.isEmpty && !it.isAbstract }
				testMethods.each {  
					newInstance := (Test) newType.make
					
					try {
						newInstance.setup
						it.callOn(newInstance, null)
						newInstance.teardown
						
					} finally {
						// notch up / carry over some verify counts
						verifies := (Int) newInstance->verifyCount
						if (fixCtx.fixtureInstance is Test)
							verifies.times { ((Test) fixCtx.fixtureInstance).verify(true) }
					}
				}
				
			} else {
				newInstance := newType.make
				
				// use the current runner
				runner := (FancordionRunner) ThreadStack.peek("afFancordion.runner")
				result := runner.runFixture(newInstance)
				if (!result.errors.isEmpty)
					throw result.errors.first
			}
			
			last := Locals.instance.resultsCache[newType]
			link := fixCtx.skin.a(last.resultFile.name.toUri, cmdCtx.cmdText)
			succ := fixCtx.skin.cmdSuccess(link, false)
			fixCtx.renderBuf.add(succ)

		} catch (Err err) {
			fixCtx.errs.add(err)
			last := Locals.instance.resultsCache[newType]
			link := last != null ? fixCtx.skin.a(last.resultFile.name.toUri, cmdCtx.cmdText) : null
			fail := fixCtx.skin.cmdFailure(link ?: cmdCtx.cmdText, err.msg, false)
			fixCtx.renderBuf.add(fail)
		}
	}
}
