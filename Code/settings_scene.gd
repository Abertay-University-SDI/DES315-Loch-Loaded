extends Control

var masterVolume = AudioServer.get_bus_index("Master")
var musicVolume = AudioServer.get_bus_index("Music")
var sfxVolume = AudioServer.get_bus_index("SFX")

var masterValue
var musicValue
var sfxValue

@export var master_slider:HSlider
@export var sfx_slider:HSlider
@export var music_slider:HSlider

var screenShake


func _ready() -> void:
	load_settings_from_file()
	AudioServer.set_bus_volume_db(masterVolume, linear_to_db(masterValue))
	AudioServer.set_bus_volume_db(musicVolume, linear_to_db(musicValue))
	AudioServer.set_bus_volume_db(sfxVolume, linear_to_db(sfxValue))
	master_slider.set_value_no_signal(
		db_to_linear(AudioServer.get_bus_volume_db(masterVolume)))
	music_slider.set_value_no_signal(
		db_to_linear(AudioServer.get_bus_volume_db(musicVolume)))
	sfx_slider.set_value_no_signal(
		db_to_linear(AudioServer.get_bus_volume_db(sfxVolume)))

func load_settings_from_file():
	var file = FileAccess.open("res://Saves/save_data.txt", FileAccess.READ)
	masterValue = file.get_line().to_float()
	musicValue = file.get_line().to_float()
	sfxValue = file.get_line().to_float()
	screenShake = file.get_line()
	return
	
func save_settings_to_file():
	var file = FileAccess.open("res://Saves/save_data.txt", FileAccess.WRITE)
	file.store_line(str(masterValue).pad_decimals(2))
	file.store_line(str(musicValue).pad_decimals(2))
	file.store_line(str(sfxValue).pad_decimals(2))
	file.store_line(str(screenShake))

func _on_master_slider_value_changed(sliderValue: float) -> void:
	AudioServer.set_bus_volume_db(masterVolume, linear_to_db(sliderValue))
	masterValue = sliderValue

func _on_music_slider_value_changed(sliderValue: float) -> void:
	AudioServer.set_bus_volume_db(musicVolume, linear_to_db(sliderValue))
	musicValue = sliderValue

func _on_sound_effect_slider_value_changed(sliderValue: float) -> void:
	AudioServer.set_bus_volume_db(sfxVolume, linear_to_db(sliderValue))
	sfxValue = sliderValue

func _on_screen_shake_button_toggled(toggled_on: bool) -> void:
	screenShake = toggled_on;

func _on_back_button_pressed() -> void:
	save_settings_to_file()
	hide();
	get_tree().get_nodes_in_group("current_ui").back().show()
