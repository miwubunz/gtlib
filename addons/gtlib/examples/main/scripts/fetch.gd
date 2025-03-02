extends Control


func fetch():
	var root = $date
	var url = GTLib.node("url", root)
	var result = GTLib.node("result", root)

	var data = await GTLib.fetch(url.text)

	result.text = data.body.get_string_from_utf8()
