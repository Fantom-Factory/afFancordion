
const class TableParser {
	
	Str[][] parseTable(Str[] lines) {
		
		ctrl := (Str) (lines.find { it.trim.startsWith("-") } ?: throw ParseErr("Table not found"))
		
		colRanges := Range[,]
		last := 0
		while (last < ctrl.size) {
			start := ctrl.index("-", last)
			end := start
			while (end < ctrl.size && ctrl[end] == '-') end++
			dashes := ctrl[start..<end]
			if (!dashes.trim.isEmpty)
				colRanges.add(start..<end)
			last = end
		}

		inHeader := true
		headers  := Str[,]
		rows	 := Str[][,]
		lines.each |line| {
			if (line.trim.isEmpty)
				return

			if (inHeader) {
				if (line.trim.startsWith("-")) {
					inHeader = false
					return
				}
				colRanges.each |col, i| {
					header := getTableData(line, col).trim
					if (i < headers.size)
						headers[i] = "${headers[i]} ${header}".trim
					else
						headers.add(header)
				}
			} else {
				row := Str[,]
				colRanges.each |col| {
					row.add(getTableData(line, col).trim)
				}
				rows.add(row)
			}
		}
		
		
		Env.cur.err.printLine(headers)
		rows.each { 
			Env.cur.err.printLine(it)
		}
		return rows.insert(0, headers)
	}

	private Str getTableData(Str line, Range col) {
		if (col.start < line.size)
			if (col.end < line.size)
				return line.getRange(col)
			else
				return line.getRange(col.start..-1)
		else
			return Str.defVal
	}
}
