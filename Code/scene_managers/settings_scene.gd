extends Control

@onready var tab_container: TabContainer = $PanelContainer/MarginContainer/main_vertical_container/TabContainer

@onready var main_menu_settings: TextureRect = $Main_Menu_Settings
@onready var background: TextureRect = $Background
@onready var animation_player: AnimationPlayer = $AnimationPlayer



@export var back_button:Control

@export var main_menu:bool = false

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

@export var filmGrainButton: Button
@export var screenShakeButton: Button
@export var GMButton: Button

var screenShake
var filmGrain

var gameMode
var styleboxN: StyleBox
var styleboxP: StyleBox
var styleboxH: StyleBox

func _ready() -> void:
	styleboxN = GMButton.get_theme_stylebox("normal")
	styleboxP = GMButton.get_theme_stylebox("pressed")
	styleboxH = GMButton.get_theme_stylebox("hover")
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
	if (Global.getGameModeEasy()):
		GMButton.text = "ASSIST MODE"
		gameMode = "ASSIST MODE"
		styleboxN.bg_color = "00ff00"
		styleboxP.bg_color = "00ff00"
		styleboxH.bg_color = "00ff00"
		GMButton.add_theme_stylebox_override("normal", styleboxN)
		GMButton.add_theme_stylebox_override("pressed", styleboxP)
		GMButton.add_theme_stylebox_override("hover", styleboxH)
		
	else:
		GMButton.text = "REGULAR MODE"
		gameMode = "REGULAR MODE"
		styleboxN.bg_color = "1b7aff"
		styleboxP.bg_color = "1b7aff"
		styleboxH.bg_color = "1b7aff"
		GMButton.add_theme_stylebox_override("normal", styleboxN)
		GMButton.add_theme_stylebox_override("pressed", styleboxP)
		GMButton.add_theme_stylebox_override("hover", styleboxH)
	if (Global.getFilmGrainMode()):
		filmGrainButton.text = "Film Grain On"
	else:
		filmGrainButton.text = "Film Grain Off"
	if (Global.getScreenShakeMode()):
		screenShakeButton.text = "Screen Shake On"
	else:
		screenShakeButton.text = "Screen Shake Off"

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
		if msg == "gameMode":
			next = 6
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
		if next == 6:
			gameMode = msg
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
	file.store_line("gameMode")
	file.store_line(gameMode)

func _on_master_slider_value_changed(sliderValue: float) -> void:
	AudioServer.set_bus_volume_db(masterVolume, linear_to_db(sliderValue))
	masterValue = sliderValue

func _on_music_slider_value_changed(sliderValue: float) -> void:
	AudioServer.set_bus_volume_db(musicVolume, linear_to_db(sliderValue))
	musicValue = sliderValue

func _on_sound_effect_slider_value_changed(sliderValue: float) -> void:
	AudioServer.set_bus_volume_db(sfxVolume, linear_to_db(sliderValue))
	sfxValue = sliderValue

func _on_screen_shake_button_pressed() -> void:
	screenShake = not Global.getScreenShakeMode()
	Global.setScreenShakeMode(screenShake)
	if (screenShake):
		screenShakeButton.text = "Screen Shake On"
	else:
		screenShakeButton.text = "Screen Shake Off"

func _on_fim_grain_pressed() -> void:
	filmGrain = not Global.getFilmGrainMode()
	Global.setFilmGrainMode(filmGrain)
	if (filmGrainTextRect):
		if (filmGrain):
			filmGrainTextRect.show()
		else:
			filmGrainTextRect.hide()
	if (Global.getFilmGrainMode()):
		filmGrainButton.text = "Film Grain On"
	else:
		filmGrainButton.text = "Film Grain Off"

func _on_back_button_pressed() -> void:
	
	save_settings_to_file()
	
	if(main_menu and not main_menu_settings.visible):
		animation_player.play("exit")
		await animation_player.animation_finished
		main_menu_settings.show()
	elif(not main_menu):
		animation_player.play("exit")
		await animation_player.animation_finished
		hide()
		get_tree().get_nodes_in_group("current_ui").back().show()
	else:
		hide()
		get_tree().get_nodes_in_group("current_ui").back().show()

func _on_color_blind_list_item_selected(index: int) -> void:
	Global.setColorBlindMode(index)

func _on_visibility_changed() -> void:
	if(visible):
		if animation_player!= null:
			animation_player.play("enter")
		back_button.grab_focus()

func _on_mode_button_pressed() -> void:
	if (GMButton.text == "ASSIST MODE"):
		Global.setGameModeEasy(false)
		GMButton.text = "REGULAR MODE"
		gameMode = "REGULAR MODE"
		styleboxN.bg_color = "1b7aff"
		styleboxP.bg_color = "1b7aff"
		styleboxH.bg_color = "1b7aff"
		GMButton.add_theme_stylebox_override("normal", styleboxN)
		GMButton.add_theme_stylebox_override("pressed", styleboxP)
		GMButton.add_theme_stylebox_override("hover", styleboxH)
	else:
		Global.setGameModeEasy(true)
		GMButton.text = "ASSIST MODE"
		gameMode = "ASSIST MODE"
		styleboxN.bg_color = "00ff00"
		styleboxP.bg_color = "00ff00"
		styleboxH.bg_color = "00ff00"
		GMButton.add_theme_stylebox_override("normal", styleboxN)
		GMButton.add_theme_stylebox_override("pressed", styleboxP)
		GMButton.add_theme_stylebox_override("hover", styleboxH)


func main_menu_appear()-> void:
	animation_player.play("enter")
	background.show()
	main_menu_settings.hide()

func _on_sound_pressed() -> void:
	tab_container.current_tab = 0
	main_menu_appear()



func _on_accessibility_pressed() -> void:
	tab_container.current_tab = 1
	main_menu_appear()


func _on_controls_pressed() -> void:
	tab_container.current_tab = 2
	main_menu_appear()
