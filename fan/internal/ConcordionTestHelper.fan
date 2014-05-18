using concurrent

@NoDoc
mixin ConcordionTestHelper {

	Void _concordion_setUp() {
		// write to our own buf, we don't need nesting and we don't then interfere with other rendering stacks
		Actor.locals["afConcordion.renderBuf"] 	= StrBuf()
		Actor.locals["afConcordion.errors"] 	= Err[,]
	}

	Void _concordion_tearDown() {
		Actor.locals.remove("afConcordion.renderBuf")
		Actor.locals.remove("afConcordion.errors")
	}
	
	StrBuf _concordion_renderBuf() {
		Actor.locals["afConcordion.renderBuf"]
	}

	Err[] _concordion_errors() {
		Actor.locals["afConcordion.errors"]
	}
	
}
