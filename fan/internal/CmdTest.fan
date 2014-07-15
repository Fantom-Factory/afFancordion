
internal class CmdTest : Command {
	
	override Void doCmd(FixtureCtx fixCtx, Uri cmdUrl, Str cmdText) {		
		testPod := fixCtx.fixtureInstance.typeof.pod
		
		Env.cur.err.printLine(cmdUrl.pathStr)
		Env.cur.err.printLine(testPod)
		Env.cur.err.printLine(testPod.types)
		// todo: allow qnames to test multiple pods
		// maybe not - 'cos then we also need to qualify the output file name
		newType		:= testPod.type(cmdUrl.pathStr, false)
		if (newType == null) {
			// TODO: scan file system for type and load fixture as script
			// but currently our runner is only launched via fant which only runs from a pod 
			// actually - that's a lie, fant can run scripts too! - http://fantom.org/doc/docTools/Fant.html#running
			throw Err("Wot no Fixture?")
		}
		
		// ensure it's a fixture so we have an output HTML file to link to
		// we could link to unit tests - but then we'd need to make it look pretty.
		// save it for the next project - or a plugin!
		if (!newType.hasFacet(Fixture#))
			throw ArgErr(ErrMsgs.fixtureFacetNotFound(newType))

		// TODO: guess the html file url until we can steal the concordion result obj 
		textLink := `${newType.name}.html`
		
		if (newType.fits(Test#)) {			
			// if only fant was written in Fantom!
			testMethods := newType.methods.findAll { it.name.startsWith("test") && it.params.isEmpty && !it.isAbstract }
			testMethods.each {  
				newInstance := (Test) newType.make
				
				newInstance.setup
				
				it.callOn(newInstance, null)
				
				newInstance.teardown
			}
			
		} else {
			newInstance := newType.make
			
			runner := (ConcordionRunner) ThreadStack.peek("afConcordion.runner")
			runner.runFixture(newInstance)
		}
		
		link := fixCtx.skin.a(textLink, cmdText)
		succ := fixCtx.skin.cmdSuccess(link, false)
		fixCtx.renderBuf.add(succ)
	}
}
