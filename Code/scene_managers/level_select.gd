extends Control

const LEVEL_1 := preload("res://Scenes/Level/level_1.tscn")
const LEVEL_2 := preload("res://Scenes/Level/level_2.tscn")
const LEVEL_3 := preload("res://Scenes/Level/level_3.tscn")
const LEVEL_BOSS := preload("res://Scenes/Level/level_boss.tscn")
const TEST_LEVEL := preload("res://Scenes/Level/test_scene.tscn")

func _on_level_1_pressed() -> void:
	SceneTransition.transition_to(LEVEL_1)

func _on_level_2_pressed() -> void:
	SceneTransition.transition_to(LEVEL_2)

func _on_level_3_pressed() -> void:
	SceneTransition.transition_to(LEVEL_3)

func _on_level_boss_pressed() -> void:
	SceneTransition.transition_to(LEVEL_BOSS)

func _on_to_studio_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/studio.tscn")
