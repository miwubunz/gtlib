extends Control


func date() -> void:
	var root = $HBoxContainer/date
	var date1 = GTLib.node("date1", root)
	var date2 = GTLib.node("date2", root)
	var result = GTLib.node("result", root)

	var data = GTLib.date_difference_iso_8601(date1.text, date2.text)

	result.text = "days: %s\nweeks: %s\nmonths: %s\nyears: %s" % [data.days, data.weeks, data.months, data.years]


func timestamp() -> void:
	var root = $HBoxContainer/timestamp
	var time1 = GTLib.node("time1", root)
	var time2 = GTLib.node("time2", root)
	var result = GTLib.node("result", root)

	var data = GTLib.time_difference_24h(time1.text, time2.text)

	result.text = "seconds: %s\nminutes: %s\nhours: %s" % [data.seconds, data.minutes, data.hours]


func ms():
	var root = $HBoxContainer/ms
	var ms = GTLib.node("ms", root)
	var result = GTLib.node("result", root)

	var data = GTLib.time_from_ms(int(ms.text))

	result.text = "seconds: %s\nminutes: %s\nhours: %s" % [data.seconds, data.minutes, data.hours]
