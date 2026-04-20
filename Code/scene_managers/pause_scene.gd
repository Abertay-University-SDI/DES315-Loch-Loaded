extends Control
@onready var settings = $"../SettingsScene"
@onready var pause_ui = $"."
@onready var back_button:TextureButton = $TextureRect/Exit
@onready var anim = $CasseteAnim

func _on_resume_pressed() -> void:
	get_tree().paused = false
	get_tree().get_nodes_in_group("current_ui").back().show()
	hide()


func _on_exit_pressed() -> void:
	get_tree().paused = false
	SceneTransition.transition_to_path("res://Scenes/UI/title_screen.tscn")


func _on_settings_pressed() -> void:
	pause_ui.hide()
	settings.show()


func _on_resume_visibility_changed() -> void:
	if visible:
		anim.play("Slide")
		back_button.grab_focus()
		await anim.animation_finished
		anim.play("idle")
