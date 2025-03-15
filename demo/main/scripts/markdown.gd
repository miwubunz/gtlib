extends VBoxContainer

var gtlib = GTLib.new()

func markdown() -> void:
	$RichTextLabel.text = gtlib.markdown_to_bbcode($TextEdit.text)
