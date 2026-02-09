extends Control

const LEVEL_1 := preload("res://Scenes/Level/test_scene.tscn")
const LEVEL_2 := preload("res://Scenes/Level/settings_scene.tscn")

func _on_level_1_pressed() -> void:
	get_tree().change_scene_to_packed(LEVEL_1)
	
func _on_level_2_pressed() -> void:
	get_tree().change_scene_to_packed(LEVEL_2)
