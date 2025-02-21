@tool
extends EditorPlugin

const NAME = 'GTools'

func _enter_tree() -> void:
	add_autoload_singleton(NAME, "res://addons/gtools/gtools.gd")


func _exit_tree() -> void:
	remove_autoload_singleton(NAME)
