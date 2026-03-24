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

enum ControllerType {
	XBOX,
	PLAYSTATION,
	SWITCH,
	UNKNOWN
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
			input_label.text = get_input_text(events[0])
		else:
			input_label.text = ""
			
		action_list.add_child(button)
		button.pressed.connect(_on_input_button_pressed.bind(button, action))


func _on_input_button_pressed(button, action):
	if !is_remapping:
		is_remapping = true
		action_to_remap = action
		remapping_button = button
		button.find_child("LabelInput").text = "Press any key (ESC to cancel)"


func _input(event):
	if is_remapping:
		if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
			is_remapping = false
			action_to_remap = null
			remapping_button = null
			_create_action_list()
			return
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
	button.find_child("LabelInput").text = get_input_text(event)


func _on_reset_button_pressed():
	InputMap.load_from_project_settings()
	_create_action_list()
	save_settings_to_file()

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

func get_controller_type(device_id: int) -> int:
	var name = Input.get_joy_name(device_id).to_lower()
	
	if name.find("xbox") != -1 or name.find("microsoft") != -1:
		return ControllerType.XBOX
	
	elif name.find("playstation") != -1 or name.find("dualshock") != -1 or name.find("dualsense") != -1 or name.find("ps4") != -1 or name.find("ps5") != -1:
		return ControllerType.PLAYSTATION
	
	elif name.find("switch") != -1 or name.find("nintendo") != -1 or name.find("pro controller") != -1:
		return ControllerType.SWITCH
	
	return ControllerType.UNKNOWN

func get_input_text(event: InputEvent) -> String:
	var type = get_controller_type(0)

	match type:
		ControllerType.XBOX:
			print("Xbox layout")
		ControllerType.PLAYSTATION:
			print("PlayStation layout")
		ControllerType.SWITCH:
			print("Switch layout")

	if event is InputEventKey:
		return event.as_text().trim_suffix(" (Physical)")
	
	elif event is InputEventMouseButton:
		return event.as_text()
	
	elif event is InputEventJoypadButton:
		return _get_joypad_button_name(event.button_index, type)
	
	elif event is InputEventJoypadMotion:
		return _get_joypad_axis_name(event.axis, event.axis_value)
	
	return "Unknown"

func _get_joypad_button_name(button: int, type: ControllerType) -> String:
	match button:
		JOY_BUTTON_A: 
			if type == ControllerType.XBOX:
				return "A"
			elif type == ControllerType.PLAYSTATION:
				return "CROSS"
			elif type == ControllerType.SWITCH:
				return "B"
			else:
				return "Button %d" % button
		JOY_BUTTON_B: 
			if type == ControllerType.XBOX:
				return "B"
			elif type == ControllerType.PLAYSTATION:
				return "CIRCLE"
			elif type == ControllerType.SWITCH:
				return "A"
			else:
				return "Button %d" % button
		JOY_BUTTON_X: 
			if type == ControllerType.XBOX:
				return "X"
			elif type == ControllerType.PLAYSTATION:
				return "SQUARE"
			elif type == ControllerType.SWITCH:
				return "Y"
			else:
				return "Button %d" % button
		JOY_BUTTON_Y: 
			if type == ControllerType.XBOX:
				return "Y"
			elif type == ControllerType.PLAYSTATION:
				return "TRIANGLE"
			elif type == ControllerType.SWITCH:
				return "X"
			else:
				return "Button %d" % button
		JOY_BUTTON_LEFT_SHOULDER:
			return "LB"
		JOY_BUTTON_RIGHT_SHOULDER:
			return "RB"
		JOY_BUTTON_BACK: 
			return "Back"
		JOY_BUTTON_START: 
			return "Start"
		JOY_BUTTON_LEFT_STICK: 
			return "L3"
		JOY_BUTTON_RIGHT_STICK: 
			return "R3"
		JOY_BUTTON_DPAD_UP: 
			return "D-Pad Up"
		JOY_BUTTON_DPAD_DOWN: 
			return "D-Pad Down"
		JOY_BUTTON_DPAD_LEFT: 
			return "D-Pad Left"
		JOY_BUTTON_DPAD_RIGHT: 
			return "D-Pad Right"
		_: 
			return "Button %d" % button

func _get_joypad_axis_name(axis: int, value: float) -> String:
	var dir = ""
	if value > 0:
		dir = "+"
	else:
		dir = "-"
	
	match axis:
		JOY_AXIS_LEFT_X:
			if (dir == "+"):
				return "Left Stick Right" 
			else:
				return "Left Stick Left"
		JOY_AXIS_LEFT_Y:
			if (dir == "+"):
				return "Left Stick Down" 
			else:
				return "Left Stick Up"
		JOY_AXIS_RIGHT_X:
			if (dir == "+"):
				return "Right Stick Right"
			else:
				return "Right Stick Left"
		JOY_AXIS_RIGHT_Y:
			if (dir == "+"):
				return "Right Stick Down"
			else:
				return "Right Stick Up"
		JOY_AXIS_TRIGGER_LEFT:
			return "LT"
		JOY_AXIS_TRIGGER_RIGHT:
			return "RT"
		_: return "Axis %d" % axis
