extends Control


func random_id():
	var root = $date
	var min = GTLib.node("min", root)
	var max = GTLib.node("max", root)
	var result = GTLib.node("result", root)

	var data = GTLib.random_id(int(min.text), int(max.text))

	result.text = str(data)
