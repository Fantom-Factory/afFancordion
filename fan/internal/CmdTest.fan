
internal class CmdTest : Command {
	
	override Void doCmd(FixtureCtx fixCtx, Uri cmdUrl, Str cmdText) {
		typeName	:= cmdUrl.pathStr
		
		newType 
			:= (typeName.contains("::")) 
			? Type.find(typeName, false)
			: fixCtx.fixtureInstance.typeof.pod?.type(typeName, false)

		if (newType == null) {
			// TODO: scan file system for type and load fixture as script
			// but currently our runner is only launched via fant which only runs from a pod 
			// actually - that's a lie, fant can run scripts too! - http://fantom.org/doc/docTools/Fant.html#running
			throw Err(ErrMsgs.cmdTest_fixtureNotFound(typeName))
		}
	
		// ensure it's a fixture so we have an output HTML file to link to
		// we could link to unit tests - but then we'd need to make it look pretty.
		// save it for the next project - or a plugin!
		if (!newType.hasFacet(Fixture#))
			throw ArgErr(ErrMsgs.fixtureFacetNotFound(newType))

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
				runner := (ConcordionRunner) ThreadStack.peek("afConcordion.runner")
				result := runner.runFixture(newInstance)
				if (!result.errors.isEmpty)
					throw result.errors.first
			}
			
			last := Locals.instance.resultsCache[newType]
			link := fixCtx.skin.a(last.resultFile.name.toUri, cmdText)
			succ := fixCtx.skin.cmdSuccess(link, false)
			fixCtx.renderBuf.add(succ)

		} catch (Err err) {
			fixCtx.errs.add(err)
			last := Locals.instance.resultsCache[newType]
			link := fixCtx.skin.a(last.resultFile.name.toUri, cmdText)
			fail := fixCtx.skin.cmdFailure(link, err.msg, false)
			fixCtx.renderBuf.add(fail)
		}
	}
}
