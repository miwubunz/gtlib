extends Control


func md() -> void:
	$HBoxContainer/markdown/text.text = GTLib.markdown_to_bbcode($HBoxContainer/markdown/TextEdit.text)


func bbcode() -> void:
	var text = $HBoxContainer/bbcode/TextEdit.text
	$HBoxContainer/bbcode/text.text = GTLib.bbcode_to_markdown(text)


func upper(new_text: String) -> void:
	if new_text.length() <= 0:
		$HBoxContainer/upper/text.text = ""
		return

	$HBoxContainer/upper/text.text = str(GTLib.is_upper(new_text))


func slugify(new_text: String) -> void:
	$HBoxContainer/slugify/text.text = str(GTLib.slugify(new_text))
