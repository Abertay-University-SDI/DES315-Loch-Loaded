extends Control

const LEVEL_1 := preload("res://Scenes/Level/level_1.tscn")
const TEST_LEVEL := preload("res://Scenes/Level/test_scene.tscn")

func _on_level_1_pressed() -> void:
	get_tree().change_scene_to_packed(LEVEL_1)
	
func _on_level_2_pressed() -> void:
	get_tree().change_scene_to_packed(TEST_LEVEL)

func _on_to_studio_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/studio.tscn"
	)
