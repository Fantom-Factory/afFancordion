using afBeanUtils::TypeCoercer

** The 'verify' command executes a Test verify method against the link text.
** Available verify methods are:
**  - eq(...)
**  - notEq(...)
**  - type(...)
**  - true(...)
**  - false(...)
**  - null(...)
**  - notNull(...)   
** 
** Arguments to the verify methods are run against the fixture and may be any valid Fantom code. 
** 
** pre>
** ** The meaning of life is [42]`verify:eq(number)`.
** @Fixture
** class ExampleFixture {
**   Int? number
** }
** <pre
** 
** Arguments for the 'eq()' and 'notEq()' methods are [type coerced]`afBeanUtils::TypeCoercer` to a 'Str'.
** Arguments for the 'true()' and 'false()' are [type coerced]`afBeanUtils::TypeCoercer` to a 'Bool'.
internal class CmdVerify : Command {
	static const Str:Str cmdCaps		:= ["verifyeq":"verifyEq", "verifynoteq":"verifyNotEq", "verifytype":"verifyType", "verify":"verify", "verifytrue":"verify", "verifyfalse":"verifyFalse", "verifynull":"verifyNull", "verifynotNull":"verifyNotNull"]
	static const Str[] doubleArgCmds	:= "verifyEq verifyNotEq verifyType".split 
	static const Str[] singleArgCmds	:= "verify verifyFalse verifyNull verifyNotNull".split
	static const Str:Type coerceTo		:= ["verifyEq":Str#, "verifyNotEq":Str#, "verifyType":Obj#, "verify":Bool#, "verifyFalse":Bool#, "verifyNull":Obj?#, "verifyNotNull":Obj?#]

	override Void runCommand(FixtureCtx fixCtx, Uri cmdUrl, Str cmdText) {
		cmd := cmdCaps[cmdUrl.scheme]	// stoopid scheme is lowercased!
		arg	:= pathStr(cmdUrl)

		if (!singleArgCmds.contains(cmd) && !doubleArgCmds.contains(cmd))
			throw CmdNotFoundErr(ErrMsgs.verifyCmdNotFound(cmd), singleArgCmds.addAll(doubleArgCmds))
		
		fromFixture	:= getFromFixture(fixCtx.fixtureInstance, arg)
		actual		:= TypeCoercer().coerce(fromFixture, coerceTo[cmd])
		expected	:= (cmd == "verifyType") ? findType(cmdText) : cmdText
		
		if (cmd == "verifyType") {
			temp    := actual
			actual   = expected
			expected = temp
		}

		try {
			// try to use the real fixture if we can so it notches up the verify count
			test := (fixCtx.fixtureInstance is Test) ? (Test) fixCtx.fixtureInstance : TestImpl()
			
			if (singleArgCmds.contains(cmd))
				test.typeof.method(cmd).callOn(test, [actual])
	
			if (doubleArgCmds.contains(cmd))
				test.typeof.method(cmd).callOn(test, [expected, actual])
			
			fixCtx.renderBuf.add(fixCtx.skin.cmdSuccess(cmdText))

		} catch (Err err) {
			fixCtx.errs.add(err)
			fixCtx.renderBuf.add(fixCtx.skin.cmdFailure(cmdText, actual))
		}
	}
	
	private static Obj findType(Str cmdText) {
		cmdText = cmdText.trim
		cmdText = cmdText.contains("::") ? cmdText : "sys::${cmdText}" 
		cmdText = cmdText.endsWith("#")  ? cmdText[0..<-1] : cmdText
		return Type.find(cmdText, true)
	}
}

@NoDoc
class TestImpl : Test { }
