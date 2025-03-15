extends VBoxContainer

var gtlib = GTLib.new()

func bb() -> void:
	$RichTextLabel.text = gtlib.bbcode_to_markdown($TextEdit.text)
