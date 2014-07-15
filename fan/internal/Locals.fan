using concurrent

** I want the individual objects stored in Actor.locals() so 3rd parties can use them if they wish. 
internal class Locals {
	
	ConcordionRunner? originalRunner {
		get { get("afConcordion.originalRunner") }
		set { set("afConcordion.originalRunner", it) }		
	}

	|->|? shutdownHook {
		get { get("afConcordion.shutdownHook") }
		set { set("afConcordion.shutdownHook", it) }
	}
	
	[Type:FixtureResult]? resultsCache {
		get { getOrAdd("afConcordion.resultsCache", Type:FixtureResult[:]) }
		set { set("afConcordion.resultsCache", it) }		
	}



	private Obj? get(Str id) {
		Actor.locals[id]
	}

	private Obj? getOrAdd(Str id, Obj obj) {
		Actor.locals.getOrAdd(id) { obj }
	}
	
	private Void set(Str id, Obj? obj) {
		if (obj == null)
			Actor.locals.remove(id)
		else
			Actor.locals[id] = obj
	}
	
	static Locals instance() {
		Locals()
	}
}
