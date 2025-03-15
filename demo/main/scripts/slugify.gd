extends VBoxContainer

var gtlib = GTLib.new()

func slugify() -> void:
	$RichTextLabel.text = gtlib.slugify($TextEdit.text)
