@tool
extends EditorPlugin

const NAME = 'GTLib'

func _enter_tree() -> void:
	if not ProjectSettings.has_setting("autoload/GTLib"):
		add_autoload_singleton(NAME, get_script().get_path().replace("plugin.gd", "gtlib.gd"))


func _exit_tree() -> void:
	if ProjectSettings.has_setting("autoload/GTLib"):
		remove_autoload_singleton(NAME)
