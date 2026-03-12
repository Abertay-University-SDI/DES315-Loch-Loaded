extends Control

@onready var input_button_scene = preload("res://Scenes/UI/input_button.tscn")
@onready var action_list = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ActionList

var SAVED_PATH = "user://input_data.cfg"

var is_remapping = false
var action_to_remap = null
var remapping_button = null

var input_actions = {
	"jump": "jump",
	"left": "left",
	"right": "right", 
	"down": "down",
	"spray": "spray",
	"punch": "punch",
	"dash": "dash",
	"yoyo": "yoyo"
}


func _ready():
	load_settings_from_file()
	_create_action_list()
	
	
func _create_action_list():
	for item in action_list.get_children():
		item.queue_free()
		
	for action in input_actions:
		var button = input_button_scene.instantiate()
		var action_label = button.find_child("LabelAction")
		var input_label = button.find_child("LabelInput")
		
		action_label.text = input_actions[action]
		
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			input_label.text = events[0].as_text().trim_suffix(" (Physical)")
		else:
			input_label.text = ""
			
		action_list.add_child(button)
		button.pressed.connect(_on_input_button_pressed.bind(button, action))


func _on_input_button_pressed(button, action):
	if !is_remapping:
		is_remapping = true
		action_to_remap = action
		remapping_button = button
		button.find_child("LabelInput").text = "Press key to bind..."


func _input(event):
	if is_remapping:
		if (
			event is InputEventKey ||
			(event is InputEventMouseButton && event.pressed) ||
			(event is InputEventJoypadButton && event.pressed) ||
			(event is InputEventJoypadMotion)
		):
			if event is InputEventMouseButton && event.double_click:
				event.double_click = false
				
			if event is InputEventJoypadMotion:
				if abs(event.axis_value) < 0.5:
					return
			
			InputMap.action_erase_events(action_to_remap)
			InputMap.action_add_event(action_to_remap, event)
			_update_action_list(remapping_button, event)
			save_settings_to_file()
			
			is_remapping = false
			action_to_remap = null
			remapping_button = null
			
			accept_event()


func _update_action_list(button, event):
	button.find_child("LabelInput").text = event.as_text().trim_suffix(" (Physical)")


func _on_reset_button_pressed():
	InputMap.load_from_project_settings()
	_create_action_list()

func load_settings_from_file():
	var config = ConfigFile.new()
	var err = config.load(SAVED_PATH)
	
	if err != OK:
		return
	
	for action in input_actions:
		if config.has_section_key("input", action):
			var event = config.get_value("input", action)
			if event is InputEvent:
				InputMap.action_erase_events(action)
				InputMap.action_add_event(action, event)
	
func save_settings_to_file():
	var config = ConfigFile.new()
	
	for action in input_actions:
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			config.set_value("input", action, events[0])
	
	config.save(SAVED_PATH)
