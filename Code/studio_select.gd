extends Control

const LEVEL_SELECT := preload("res://Scenes/Level/level_select.tscn")
#const SETTINGS := preload("res://Scenes/Level/settings_scene.tscn")

func _on_level_select_pressed() -> void:
	get_tree().change_scene_to_packed(LEVEL_SELECT)
	
#func _on_settings_pressed() -> void:
	#get_tree().change_scene_to_packed(SETTINGS)

func _on_exit_pressed() -> void:
	get_tree().quit()
