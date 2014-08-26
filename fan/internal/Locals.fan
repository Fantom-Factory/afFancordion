using concurrent

** I want the individual objects stored in Actor.locals() so 3rd parties can use them if they wish. 
internal class Locals {
	
	FancordionRunner? originalRunner {
		get { get("afFancordion.originalRunner") }
		set { set("afFancordion.originalRunner", it) }		
	}

	|->|? shutdownHook {
		get { get("afFancordion.shutdownHook") }
		set { set("afFancordion.shutdownHook", it) }
	}
	
	[Type:FixtureResult]? resultsCache {
		get { getOrAdd("afFancordion.resultsCache", Type:FixtureResult[:] { ordered=true }) }
		set { set("afFancordion.resultsCache", it) }		
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
