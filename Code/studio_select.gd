extends Control

const LEVEL_SELECT := preload("res://Scenes/Level/level_select.tscn")

@onready var settings = $SettingsScene;
@onready var studio_ui = $StudioUI;

func _on_level_select_button_pressed() -> void:
	get_tree().change_scene_to_packed(LEVEL_SELECT)

func _on_settings_button_pressed() -> void:
	studio_ui.hide();
	settings.show();

func _on_exit_button_pressed() -> void:
	get_tree().quit()
