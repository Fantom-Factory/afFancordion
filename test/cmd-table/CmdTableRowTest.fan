using afBounce

**  See [How to refer to a row index in a Fancordion fixture table?]`http://stackoverflow.com/questions/34236040/how-to-refer-to-a-row-index-in-a-fancordion-fixture-table/`.
** 
**   table:
**   col[0]+verifyEq:getCountries[#ROW]["code"]
**   col[1]+verifyEq:getCountries[#ROW]["name"]
**
**   Country Code	Country Name
**   ------------	------------
**   AU	            Australia
**   NZ	            New Zealand
**   UK	            United Kingdom
** 
class CmdTableRowTest : ConTest {

	[Str:Obj?][] getCountries() {
		[["code":"AU", "name":"Australia"], ["code":"NZ", "name":"New Zealand"], ["code":"UK", "name":"United Kingdom"]]
	}
	
	override Void doTest() {
		Element("td.success")[0].verifyTextEq("AU")
		Element("td.success")[1].verifyTextEq("Australia")
	}
}