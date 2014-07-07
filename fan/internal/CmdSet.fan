using afBeanUtils

internal class CmdSet : Command {

	override Str doCmd(Uri cmdUrl, Str cmdText) {
		
		fieldName	:= cmdUrl.pathStr
		fieldValue	:= cmdText.toCode

		echo("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")

		return
"""<% |->| { // scope the local variables so we can embed the command more than once
      cmdUrl  := ${cmdUrl.toCode}
      cmdText := ${cmdText.toCode}
      try {
          %><%= _concordion_skin.success("Whoop") %><%
          echo("##########################################")
          %><%= _concordion_skin.success("Whoop") %><%
          typeCoercer := afBeanUtils::TypeCoercer()
          field       := this.typeof.field(${fieldName.toCode}, true)
          fieldValue  := typeCoercer.coerce(${fieldValue}, field.type)
          field.set(_concordion_testInstance, fieldValue)
          %><%= _concordion_skin.success(${fieldValue}) %><%
      } catch (Err err) {
          _concordion_errors.add(err)
          %><%= _concordion_skin.err(cmdUrl, cmdText, err) %><%
      }
      }() %>"""
	}
}
