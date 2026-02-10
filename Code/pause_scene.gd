extends Control

const GAME_SCENE := preload("res://Scenes/Level/test_scene.tscn")
const STUDIO_SCENE := preload("res://Scenes/Level/studio.tscn")

@onready var settings = $SettingsScene;
@onready var pause = $PauseSceneUI;

func _on_back_game_button_pressed() -> void:
	get_tree().change_scene_to_packed(GAME_SCENE)


func _on_back_studio_button_pressed() -> void:
	get_tree().change_scene_to_packed(STUDIO_SCENE)


func _on_settings_button_pressed() -> void:
	pause.hide();
	settings.show();


func _on_exit_button_pressed() -> void:
	get_tree().quit()
