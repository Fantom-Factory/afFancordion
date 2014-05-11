using afIoc

const class ConcordionModule {
	
	static Void bind(ServiceBinder binder) {
		binder.bind(ConcordionRunner#)
	}
}
