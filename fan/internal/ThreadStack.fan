using concurrent

** I've recently become a fan of threaded stacks - they get me outa a whole lot of trouble!
internal class ThreadStack {

	private Str		stackId
	private Obj[]	stack	:= [,]
		

	** static use only
	private new make(Str stackId) {
		this.stackId = stackId
	}

	private Obj? get(Int index, Bool checked := true) {
		if (checked && stack.isEmpty)
			throw Err("ThreadStack with id '$stackId' is empty")
		if (checked && stack.getSafe(index) == null)
			throw Err("ThreadStack with id '$stackId' only has ${stack.size} elements")
		return stack.getSafe(index)
	}
	
	override Str toStr() {
		str	:= "ThreadStack '${stackId}' is ($stack.size) deep:"
		stack.each { str += "\n  - $it" }
		return str
	}

	
	// ---- public static methods --------------------------------------------------------------------------------------
	
	static Obj? push(Str stackId, Obj stackObj, |Obj->Obj?|? func := null) {
		threadStack	:= getOrMakeStack(stackId)
		threadStack.stack.push(stackObj)
		
		if (func != null)
			try	return func.call(stackObj)
			finally	pop(stackId)
		else
			return null
	}

	static Void pop(Str stackId) {
		threadStack := getStack(stackId, true)
		threadStack.stack.pop
		if (threadStack.stack.isEmpty)
			Actor.locals.remove(stackId)			
	}

	static Obj? peek(Str stackId, Bool checked := true) {
		getStack(stackId, checked)?.get(-1, checked)
	}

	static Obj? peekParent(Str stackId, Bool checked := true) {
		getStack(stackId, checked)?.get(-2, checked) 
	}

	static Obj[]? elements(Str stackId, Bool checked := true) {
		getStack(stackId, checked)?.stack
	}

	private static ThreadStack? getStack(Str stackId, Bool checked) {
		Actor.locals.get(stackId) ?: (checked ? throw Err("Could not find ThreadStack in Actor.locals() with id '$stackId'") : null)		
	}

	private static ThreadStack getOrMakeStack(Str stackId) {
		Actor.locals.getOrAdd(stackId) { ThreadStack(stackId) }
	}
}
