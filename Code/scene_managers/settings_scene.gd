extends Control

@export var back_button:Button

var SAVED_PATH = "res://Saves/save_data.txt"

var masterVolume = AudioServer.get_bus_index("Master")
var musicVolume = AudioServer.get_bus_index("Music")
var sfxVolume = AudioServer.get_bus_index("SFX")

var masterValue = 1
var musicValue = 1
var sfxValue = 1

@export var master_slider:HSlider
@export var sfx_slider:HSlider
@export var music_slider:HSlider

@export var filmGrainTextRect: TextureRect

var screenShake
var filmGrain

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
	if not FileAccess.file_exists(SAVED_PATH):
		return
	var file = FileAccess.open(SAVED_PATH, FileAccess.READ)
	var contents = file.get_as_text()
	var text_file_contents : PackedStringArray = contents.split("\n", true)
	var next = 0
	for msg in text_file_contents:
		if msg == "masterValue":
			next = 1
		if msg == "musicValue":
			next = 2
		if msg == "sfxValue":
			next = 3
		if msg == "screenShake":
			next = 4
		if msg == "filmGrain":
			next = 5
		if next == 1:
			masterValue = msg.to_float()
		if next == 2:
			musicValue = msg.to_float()
		if next == 3:
			sfxValue = msg.to_float()
		if next == 4:
			screenShake = msg
		if next == 5:
			filmGrain = msg
	return

func save_settings_to_file():
	var file = FileAccess.open(SAVED_PATH, FileAccess.WRITE)
	file.store_line("masterValue")
	file.store_line(str(masterValue).pad_decimals(2))
	file.store_line("musicValue")
	file.store_line(str(musicValue).pad_decimals(2))
	file.store_line("sfxValue")
	file.store_line(str(sfxValue).pad_decimals(2))
	file.store_line("screenShake")
	file.store_line(str(screenShake))
	file.store_line("filmGrain")
	file.store_line(str(filmGrain))

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
	screenShake = toggled_on

func _on_fim_grain_toggled(toggled_on: bool) -> void:
	filmGrain = toggled_on
	if (filmGrain):
		filmGrainTextRect.show()
	else:
		filmGrainTextRect.hide()

func _on_back_button_pressed() -> void:
	save_settings_to_file()
	hide();
	get_tree().get_nodes_in_group("current_ui").back().show()

func _on_color_blind_list_item_selected(index: int) -> void:
	Global.setColorBlindMode(index)

func _on_controlls_button_toggled(_toggled_on: bool) -> void:
	# show controlls, have ability to change controlls
	return

func _on_visibility_changed() -> void:
	if(visible):
		back_button.grab_focus()
