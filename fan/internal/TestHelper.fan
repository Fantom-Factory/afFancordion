using concurrent

@NoDoc
mixin TestHelper {

	// nullable 'cos it probably won't be set in the ctor
	abstract ConcordionSkin? _concordion_skin

	// nullable 'cos it probably won't be set in the ctor
	abstract Test? _concordion_testInstance
	
	Void _concordion_setUp() {
		// write to our own StrBuf. 
		// We don't need nesting and we don't then interfere with other rendering stacks
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
