extends Control

const studio := preload("res://Scenes/UI/studio.tscn")
@onready var settings = $SettingsScene
@onready var title_screen_ui = $title_screen_ui
@onready var credits_screen = $credits_screen
@export var GMButton: Button



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_studio_button_pressed() -> void:
	SceneTransition.transition_to_path("res://Scenes/Level/level_2_blocking.tscn")


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


func _on_mode_button_pressed() -> void:
	var styleboxN: StyleBox = GMButton.get_theme_stylebox("normal")
	var styleboxP: StyleBox = GMButton.get_theme_stylebox("pressed")
	var styleboxH: StyleBox = GMButton.get_theme_stylebox("hover")
	if (GMButton.text == "EASY MODE"):
		Global.setGameModeEasy(false)
		GMButton.text = "HARD MODE"
		styleboxN.bg_color = "ff0000"
		styleboxP.bg_color = "ff0000"
		styleboxH.bg_color = "ff0000"
		GMButton.add_theme_stylebox_override("normal", styleboxN)
		GMButton.add_theme_stylebox_override("pressed", styleboxP)
		GMButton.add_theme_stylebox_override("hover", styleboxH)
	else:
		Global.setGameModeEasy(true)
		GMButton.text = "EASY MODE"
		styleboxN.bg_color = "00ff00"
		styleboxP.bg_color = "00ff00"
		styleboxH.bg_color = "00ff00"
		GMButton.add_theme_stylebox_override("normal", styleboxN)
		GMButton.add_theme_stylebox_override("pressed", styleboxP)
		GMButton.add_theme_stylebox_override("hover", styleboxH)
