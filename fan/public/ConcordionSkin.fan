using concurrent

@NoDoc
mixin ConcordionSkin {

	abstract Int buttonId
	
	virtual Str example() {
		"""<div class="example">"""
	}
	virtual Str exampleEnd() {
		"""</div>"""
	}
	
	virtual Str success(Str expected) {
		"""<span class="success">${expected.toXml}</span>"""
	}

	virtual Str failure(Str expected, Obj? actual) {
		"""<span class="failure"><del class="expected">${expected.toXml}</del> ${actual?.toStr?.toXml}</span>"""
	}

	virtual Str err(Str expected, Str expression, Err err) {
		buttonId++
		stack := err.traceToStr.splitLines.join("") { "<span class=\"stackTraceEntry\">${it}</span>\n" }
		return
		"""<span class="failure">
		     <del class="expected">${expected.toXml}</del>
		   </span>
		   <span class="exceptionMessage">${err.msg.toXml}</span>
		   <input id="stackTraceButton${buttonId}" type="button" class="stackTraceButton" onclick="javascript:toggleStackTrace('${buttonId}')" value="View Stack" />
		   <span class="stackTrace" id="stackTrace${buttonId}">
		     <span>While evaluating expression: <code>${expression}</code></span>
		     <span class="stackTraceExceptionMessage">${err.typeof} : ${err.msg}</span>
		     ${stack}
		   </span>
		   """
	}
	
}

internal class ConcordionSkinImpl : ConcordionSkin { 
	override Int buttonId	// FIXME: buttonID
}
