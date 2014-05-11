
class ConcordionTests {
	
	Type[] findTests() {
		this.typeof.pod.types.findAll { it.isMixin && it.fits(ConcordionTest#) }
	}
}
