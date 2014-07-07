using afBeanUtils

internal class CmdSet : Command {

	override Str doCmd(Uri cmdUrl, Str cmdText) {
		
		fieldName	:= cmdUrl.pathStr
		fieldValue	:= cmdText.toCode

		echo("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")

		return
"""<% { // scope the local variables so we can embed the command more than once
      typeCoercer := afBeanUtils::TypeCoercer()
      field       := this.typeof.field(${fieldName.toCode}, true)
      fieldValue  := typeCoercer.coerce(${fieldValue}, field.type)
      field.set(_concordion_testInstance, fieldValue)
      } %>"""
	}
}
