extends Control

const LEVEL_SELECT := preload("res://Scenes/UI/level_select.tscn")
@onready var settings = $SettingsScene
@onready var studio_ui = $studio_menu
@export var button:Button


func _ready() -> void:
	button.grab_focus()

func _on_level_select_button_pressed() -> void:
	get_tree().change_scene_to_packed(LEVEL_SELECT)

func _on_settings_button_pressed() -> void:
	studio_ui.hide()
	settings.show()

func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_main_menu_button_pressed() -> void:
	SceneTransition.transition_to_path("res://Scenes/UI/title_screen.tscn")


func _on_spray_editor_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/spray_editor.tscn")
