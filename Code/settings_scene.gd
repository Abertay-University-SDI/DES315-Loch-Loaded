extends Control

var masterVolume = AudioServer.get_bus_index("Master")
var musicVolume = AudioServer.get_bus_index("Music")
var sfxVolume = AudioServer.get_bus_index("SFX")

@export var master_slider:HSlider
@export var sfx_slider:HSlider
@export var music_slider:HSlider


var screenShake

func _ready() -> void:
	master_slider.set_value_no_signal(
		db_to_linear(AudioServer.get_bus_volume_db(masterVolume)))
	music_slider.set_value_no_signal(
		db_to_linear(AudioServer.get_bus_volume_db(musicVolume)))
	sfx_slider.set_value_no_signal(
		db_to_linear(AudioServer.get_bus_volume_db(sfxVolume)))
	

func _on_master_slider_value_changed(masterValue: float) -> void:
	AudioServer.set_bus_volume_db(masterVolume, linear_to_db(masterValue))

func _on_music_slider_value_changed(musicValue: float) -> void:
	AudioServer.set_bus_volume_db(musicVolume, linear_to_db(musicValue))

func _on_sound_effect_slider_value_changed(sfxValue: float) -> void:
	AudioServer.set_bus_volume_db(sfxVolume, linear_to_db(sfxValue))

func _on_screen_shake_button_toggled(toggled_on: bool) -> void:
	screenShake = toggled_on;

func _on_back_button_pressed() -> void:
	hide();
	get_tree().get_nodes_in_group("current_ui").back().show()
