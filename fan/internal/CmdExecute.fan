using afBeanUtils
using afPlastic

internal class CmdExecute : Command {
	private static const PlasticCompiler compiler	:= PlasticCompiler()

	override Void doCmd(FixtureCtx fixCtx, Uri cmdUrl, Str cmdText) {
		
		fcode := cmdUrl.toStr[cmdUrl.scheme.size+1..-1].replace("#TEXT", cmdText.toCode)
		model := PlasticClassModel("ExecuteCmd", false)
		model.extend(CmdExecuteHelper#)
		model.overrideMethod(CmdExecuteHelper#doExecute, "((${fixCtx.fixtureInstance.typeof.qname}) fixture).${fcode}")
		help := (CmdExecuteHelper) compiler.compileModel(model).make

		// run the command!
		help.execute(fixCtx, cmdUrl, cmdText)
	}
}

@NoDoc
abstract class CmdExecuteHelper {

	Void execute(FixtureCtx fixCtx, Uri cmdUrl, Str cmdText) {
		try {
			doExecute(fixCtx.fixtureInstance)
			fixCtx.renderBuf.add(fixCtx.skin.cmdSuccess(cmdText))

		} catch (Err err) {
			fixCtx.errs.add(err)
			fixCtx.renderBuf.add(fixCtx.skin.cmdErr(cmdUrl, cmdText, err))
		}
	}
	
	abstract Void doExecute(Obj fixture)
}