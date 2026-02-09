extends Control

var masterVolume = AudioServer.get_bus_index("Master")
var musicVolume = AudioServer.get_bus_index("Music")
var sfxVolume = AudioServer.get_bus_index("SFX")

func _on_master_slider_value_changed(masterValue: float) -> void:
	AudioServer.set_bus_volume_db(masterVolume, linear_to_db(masterValue))

func _on_music_slider_value_changed(musicValue: float) -> void:
	AudioServer.set_bus_volume_db(musicVolume, linear_to_db(musicValue))

func _on_sound_effect_slider_value_changed(sfxValue: float) -> void:
	AudioServer.set_bus_volume_db(sfxVolume, linear_to_db(sfxValue))
