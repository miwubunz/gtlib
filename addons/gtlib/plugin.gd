@tool
extends EditorPlugin

const NAME = 'GTLib'

func _enter_tree() -> void:
	add_autoload_singleton(NAME, get_script().get_path().replace("plugin.gd", "gtlib.gd"))


func _exit_tree() -> void:
	remove_autoload_singleton(NAME)
