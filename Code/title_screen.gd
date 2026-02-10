extends Control

const studio := preload("res://Scenes/Level/studio.tscn")
@onready var settings = $SettingsScene;
@onready var title_screen_ui = $title_screen_ui;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_studio_button_pressed() -> void:
	get_tree().change_scene_to_packed(studio)


func _on_settings_button_pressed() -> void:
	title_screen_ui.hide();
	settings.show();


func _on_credits_button_pressed() -> void:
	pass # Replace with function body.


func _on_exit_button_pressed() -> void:
	get_tree().quit()
