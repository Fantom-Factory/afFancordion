using concurrent

** Implement to create a skin for generated HTML result files.
mixin ConcordionSkin {

	private Int buttonId() {
		Actor.locals["afConcordion.buttonId"]
	}
	
	virtual FixtureMeta fixtureMeta() {
		Actor.locals["afConcordion.meta"]
	}

	virtual Str html() {
		Actor.locals["afConcordion.buttonId"] = 0
		return """<!DOCTYPE html>\n<html xmlns="http://www.w3.org/1999/xhtml">\n"""
	}
	virtual Str htmlEnd() {
		Actor.locals.remove("afConcordion.buttonId")
		return """</html>\n"""
	}
	
	virtual Str head() {
		buf	:= StrBuf()
		buf.add("<head>\n")
		buf.add("\t<title>${fixtureMeta.title} : Concordion</title>\n")
//	<style>
//		{{{ concordionCss }}}
//	</style>
//	<script type="text/javascript">
//		{{{ visibilityToggler }}}	
//	</script>
		buf.add("</head>\n")
		return buf.toStr
	}

	virtual Str body() {
		"""<body>\n\t<main>\n"""
	}
	virtual Str bodyEnd() {
		"""\t</main>\n</body>\n"""
	}
	
	virtual Str example() {
		"""<div class="example">\n"""
	}
	virtual Str exampleEnd() {
		"""</div>\n"""
	}
	
	virtual Str success(Str expected) {
		"""<span class="success">${expected.toXml}</span>"""
	}

	virtual Str failure(Str expected, Obj? actual) {
		"""<span class="failure"><del class="expected">${expected.toXml}</del> ${actual?.toStr?.toXml}</span>"""
	}

	virtual Str err(Uri cmdUrl, Str cmdText, Err err) {
		Actor.locals["afConcordion.buttonId"] = buttonId + 1
		stack := err.traceToStr.splitLines.join("") { "<span class=\"stackTraceEntry\">${it}</span>\n" }
		return
		"""<span class="failure">
		     <del class="expected">${cmdText.toXml}</del>
		   </span>
		   <span class="exceptionMessage">${err.msg.toXml}</span>
		   <input id="stackTraceButton${buttonId}" type="button" class="stackTraceButton" onclick="javascript:toggleStackTrace('${buttonId}')" value="View Stack" />
		   <span class="stackTrace" id="stackTrace${buttonId}">
		     <span>While evaluating command: <code>${cmdUrl}</code></span>
		     <span class="stackTraceExceptionMessage">${err.typeof} : ${err.msg}</span>
		     ${stack}
		   </span>
		   """
	}
}

internal class ConcordionSkinImpl : ConcordionSkin { }
