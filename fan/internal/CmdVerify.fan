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
	static const Str[] doubleArgCmds	:= "eq notEq type".split 
	static const Str[] singleArgCmds	:= "true false null notNull".split
	static const Str:Type coerceTo		:= ["eq":Str#, "notEq":Str#, "type":Obj#, "true":Bool#, "false":Bool#, "null":Obj?#, "notNull":Obj?#]

	override Void runCommand(FixtureCtx fixCtx, Uri cmdUrl, Str cmdText) {
		i 	:= pathStr(cmdUrl).index("(")?.minus(1) ?: -1
		cmd := pathStr(cmdUrl)[0..i]
		arg	:= (i != -1) ? pathStr(cmdUrl)[i+1..-1].trim : ""

		if (!singleArgCmds.contains(cmd) && !doubleArgCmds.contains(cmd))
			throw CmdNotFoundErr(ErrMsgs.verifyCmdNotFound(cmd), singleArgCmds.addAll(doubleArgCmds))
		
		if (arg.startsWith("("))
			arg = arg[1..-1]
		if (arg.endsWith(")"))
			arg = arg[0..-2]
		
		fromFixture	:= getFromFixture(fixCtx.fixtureInstance, arg)
		actual		:= TypeCoercer().coerce(fromFixture, coerceTo[cmd])
		expected	:= (cmd == "type") ? findType(cmdText) : cmdText
		
		if (cmd == "type") {
			temp    := actual
			actual   = expected
			expected = temp
		}

		try {
			// try to use the real fixture if we can so it notches up the verify count
			test := (fixCtx.fixtureInstance is Test) ? (Test) fixCtx.fixtureInstance : TestImpl()
			
			if (singleArgCmds.contains(cmd)) {
				vName := "verify" + (cmd.equalsIgnoreCase("true") ? "" : cmd).capitalize
				test.typeof.method(vName).callOn(test, [actual])
			}
	
			if (doubleArgCmds.contains(cmd)) {
				vName := "verify${cmd.capitalize}"
				test.typeof.method(vName).callOn(test, [expected, actual])
			}
			
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
