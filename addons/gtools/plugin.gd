@tool
extends EditorPlugin

const NAME = 'GTLib'

func _enter_tree() -> void:
	add_autoload_singleton(NAME, "res://addons/gtools/gtlib.gd")


func _exit_tree() -> void:
	remove_autoload_singleton(NAME)
