extends Control


func _on_line_edit_text_changed(new_text: String) -> void:
	$HBoxContainer/markdown/text.text = GTLib.markdown_to_bbcode(new_text)


func bbcode(new_text: String) -> void:
	$HBoxContainer/bbcode/text.text = GTLib.bbcode_to_markdown(new_text)


func upper(new_text: String) -> void:
	if new_text.length() <= 0:
		$HBoxContainer/upper/text.text = ""
		return

	$HBoxContainer/upper/text.text = str(GTLib.is_upper(new_text))


func slugify(new_text: String) -> void:
	$HBoxContainer/slugify/text.text = str(GTLib.slugify(new_text))
