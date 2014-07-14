using afBeanUtils::TypeCoercer
using afPlastic

internal class CmdVerify : Command {
	private static const PlasticCompiler compiler	:= PlasticCompiler()
	
	override Void doCmd(FixtureCtx fixCtx, Uri cmdUrl, Str cmdText) {
		
		i 	:= cmdUrl.pathStr.index("(")?.minus(1) ?: -1
		cmd := cmdUrl.pathStr[0..i]
		arg	:= (i != -1) ? cmdUrl.pathStr[i+1..-1].trim : ""

		if (!CmdVerifyHelper.singleArgCmds.contains(cmd) && !CmdVerifyHelper.doubleArgCmds.contains(cmd))
			throw CmdNotFoundErr(ErrMsgs.verifyCmdNotFound(cmd), CmdVerifyHelper.singleArgCmds.addAll(CmdVerifyHelper.doubleArgCmds))
		
		if (arg.startsWith("("))
			arg = arg[1..-1]
		if (arg.endsWith(")"))
			arg = arg[0..-2]
		
		model := PlasticClassModel("VerifyCmd", false)
		model.extend(CmdVerifyHelper#)
		model.overrideMethod(CmdVerifyHelper#findActual, "((${fixCtx.fixtureInstance.typeof.qname}) fixture).${arg}")
		help := (CmdVerifyHelper) compiler.compileModel(model).make
		
		// run the command!
		help.verify(fixCtx, cmd, cmdUrl, cmdText)
	}
}

@NoDoc
class TestImpl : Test { }

@NoDoc
abstract class CmdVerifyHelper {
	static const Str[] doubleArgCmds	:= "eq notEq type".split 
	static const Str[] singleArgCmds	:= "true false null notNull".split
	static const Str:Type coerceTo		:= ["eq":Str#, "notEq":Str#, "type":Obj#, "true":Bool#, "false":Bool#, "null":Obj?#, "notNull":Obj?#]

	Void verify(FixtureCtx fixCtx, Str cmd, Uri cmdUrl, Str cmdText) {
		try {
			
			actual		:= TypeCoercer().coerce(findActual(fixCtx.fixtureInstance), coerceTo[cmd])
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
				html := fixCtx.skin.cmdFailure(cmdText, actual)
				fixCtx.renderBuf.add(html)
			}
			
		} catch (Err err) {
			fixCtx.errs.add(err)
			fixCtx.renderBuf.add(fixCtx.skin.cmdErr(cmdUrl, cmdText, err))
		}
	}
	
	abstract Obj findActual(Obj fixture)

	private static Obj findType(Str cmdText) {
		cmdText = cmdText.trim
		cmdText = cmdText.contains("::") ? cmdText : "sys::${cmdText}" 
		cmdText = cmdText.endsWith("#")  ? cmdText[0..<-1] : cmdText
		return Type.find(cmdText, true)
	}
}