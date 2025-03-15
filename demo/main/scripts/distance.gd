extends VBoxContainer

var gtlib = GTLib.new()

func distance() -> void:
	$RichTextLabel.text = str(gtlib.text_distance($HBoxContainer/TextEdit.text, $HBoxContainer/TextEdit2.text))
