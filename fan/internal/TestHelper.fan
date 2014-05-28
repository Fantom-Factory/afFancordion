using concurrent

@NoDoc
mixin TestHelper {

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
	
	// ---- Command Helpers -----------------------------------------------------------------------

	Str _concordion_writeSuccess(Str expected) {
		"""<span class="success">${expected.toXml}</span>"""
	}

	Str _concordion_writeFailure(Str expected, Str actual) {
		"""<span class="failure"><span class="expected">${expected.toXml}</span> ${actual.toXml}</span>"""
	}

	Str _concordion_writeErr(Str expected, Err err) {
		"""<span class="failure"><span class="expected">${expected.toXml}</span> ${err.msg.toXml}</span>"""
	}
}
