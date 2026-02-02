extends Control

const LEVEL_1 := preload("res://Scenes/world.tscn")

func _on_level_1_pressed() -> void:
	get_tree().change_scene_to_packed(LEVEL_1)
