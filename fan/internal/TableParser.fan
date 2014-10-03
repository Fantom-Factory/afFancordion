
const class TableParser {
	
	Str[][] parseTable(Str[] lines) {
		ctrl := (Str) (lines.find { it.trim.startsWith("-") } ?: throw ParseErr(ErrMsgs.cmdTable_tableNotFound(lines.join("\n"))))
		
		colRanges := Range[,]
		last := 0
		while (last < ctrl.size && ctrl.index("-", last) != null) {
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
					header := getTableData(line, col)
					if (header != null)
						if (i < headers.size)
							headers[i] = "${headers[i]} ${header}".trim
						else
							headers.add(header)
				}
			} else {
				row := Str[,]
				colRanges.each |col| {
					data := getTableData(line, col)
					if (data != null)
						row.add(data)
				}
				if (!row.isEmpty)
					rows.add(row)
			}
		}

		return rows.insert(0, headers)
	}

	private Str? getTableData(Str line, Range col) {
		data := (Str?) Str.defVal
		if (col.start < line.size)
			if (col.end < line.size)
				data = line.getRange(col).trim
			else
				data = line.getRange(col.start..-1).trim
		return data.chars.all { it == '-' } ? null : data
	}
}
