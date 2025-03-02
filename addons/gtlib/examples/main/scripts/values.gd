extends Control


func color(color: Color) -> void:
	var data = GTLib.rgb_to_normalized(color.r * 255, color.g * 255, color.b * 255, color.a)

	var root = $HBoxContainer/color
	var result = GTLib.node("result", root)

	result.text = "red: %s\ngreen: %s\nblue: %s\nalpha: %s" % [data.r, data.g, data.b, data.a]


func res() -> void:
	var root = $HBoxContainer/res
	var result = GTLib.node("result", root)
	var data = GTLib.get_recommended_resolutions()

	result.text = str(data)
	


func img() -> void:
	var root = $HBoxContainer/img
	var result = GTLib.node("result", root)
	var path = GTLib.node("img", root)
	var data = GTLib.img_to_texture(path.text)

	result.texture = data
