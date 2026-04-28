extends Control

const studio := preload("res://Scenes/UI/studio.tscn")
@onready var settings = $SettingsScene
@onready var title_screen_ui = $title_screen_ui
@onready var credits_screen = $credits_screen



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_studio_button_pressed() -> void:
	SceneTransition.transition_to_path("res://Scenes/Level/Main_Level.tscn")


func _on_spray_editor_button_pressed() -> void:
	SceneTransition.transition_to_path("res://Scenes/UI/spray_editor.tscn")


func _on_settings_button_pressed() -> void:
	title_screen_ui.hide()
	settings.show()


func _on_credits_button_pressed() -> void:
	title_screen_ui.hide()
	credits_screen.show()


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_tutorial_button_pressed() -> void:SceneTransition.transition_to_path("res://Scenes/Level/Tutorial_Level.tscn")
