using concurrent

internal class CmdTest : Command {
	
	override Void doCmd(FixtureCtx fixCtx, Uri cmdUrl, Str cmdText) {		
//		fixtureMeta := (FixtureMeta) Actor.locals["afConcordion.fixtureMeta"]
//		testPod		:= fixtureMeta.fixtureType.pod
//		
//		// TODO: allow qnames to test multiple pods
//		newType		:= testPod.type(cmdText, false)
//		if (newType == null) {
//			// TODO: scan file system for type and load fixture as script
//			// but currently our runner is only launched via fant which only runs from a pod 
//			// actually - that's a lie, fant can run scripts too! - http://fantom.org/doc/docTools/Fant.html#running
//			throw Err("Wot no Fixture?")
//		}
//		
//		newInstance := (Test?) null
//		if (newType.fits(Test#)) {
//			// TODO: make sure it's a fixture so we have a file to link to.
//			// we could link to unit tests - but then we'd need to make it look pretty.
//			// save it for the next project - or a plugin!
//			
//			// if only fant was written in Fantom!
//			testMethods := newType.methods.findAll { it.name.startsWith("test") && it.params.isEmpty && !it.isAbstract }
//			testMethods.each {  
//				newInstance = newType.make
//				
//				newInstance.setup
//				
//				it.callOn(newInstance, null)
//				
//				newInstance.teardown
//			}
//			
//		} else {
//			throw Err("TODO: run fixture")
//		}
	}
	
}
 