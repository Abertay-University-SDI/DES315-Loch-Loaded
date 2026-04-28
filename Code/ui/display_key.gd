@tool
extends Label

@export var action_name: String

var findword: String

enum ControllerType {
	XBOX,
	PLAYSTATION,
	SWITCH,
	UNKNOWN
}

func _ready() -> void: 
	text = str(text) % update_label()

func update_label() -> String:
	if not InputMap.has_action(action_name):
		return "none"

	var events = InputMap.action_get_events(action_name)
	if events.size() > 0:
		return get_input_text(events[0])
	else:
		return "Unassigned"

func get_controller_type(device_id: int) -> int:
	var controllerName = Input.get_joy_name(device_id).to_lower()
	
	if controllerName.find("xbox") != -1 or controllerName.find("microsoft") != -1 or controllerName.find("xinput") != -1:
		return ControllerType.XBOX
	
	elif controllerName.find("playstation") != -1 or controllerName.find("dualshock") != -1 or controllerName.find("dualsense") != -1 or controllerName.find("ps4") != -1 or controllerName.find("ps5") != -1:
		return ControllerType.PLAYSTATION
	
	elif controllerName.find("switch") != -1 or controllerName.find("nintendo") != -1 or controllerName.find("pro controller") != -1:
		return ControllerType.SWITCH
	
	return ControllerType.UNKNOWN

func get_input_text(event: InputEvent) -> String:
	var type = get_controller_type(0)
	
	if (type != null):
		if event is InputEventJoypadButton:
			return _get_joypad_button_name(event.button_index, type)
	
		elif event is InputEventJoypadMotion:
			return _get_joypad_axis_name(event.axis, event.axis_value)
	else:
		if event is InputEventKey:
			return event.as_text().trim_suffix(" (Physical)")
	
		elif event is InputEventMouseButton:
			return event.as_text()
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
