
internal const class Utils {
	
	**   private static const Log log	:= Utils.getLog(Wotever#)
	static Log getLog(Type type) {
//		Log.get(type.pod.name + "." + type.name)
		type.pod.log
	}

}
