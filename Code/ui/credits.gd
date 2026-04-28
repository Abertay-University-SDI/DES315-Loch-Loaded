@tool
extends RichTextLabel

@export var scroll_speed: float = 70.0 # pixels per second

var scroll_value: float = 0.0
var max_scroll: float = 6500.0


func _ready() -> void:
	bbcode_enabled = true

	# Clear first so it doesn't append multiple times in @tool mode
	text = ""

	# Top padding so credits start lower
	text += "\n\n\n\n\n\n"

	# Programmers
	text += "[center][b]Programmers[/b]\n\n"
	text += "Andrew Moore\n[img=512x512]res://Textures/Credits/andrew.png[/img]\n\n"

	text += "[b]VFX[/b]\n"
	text += "[b]UI Programmer[/b]\n"
	text += "[b]Tools Programmer[/b]\n"
	text += "Peter Mazanik\n[img=512x512]res://Textures/Credits/peter.png[/img]\n\n"

	# Artists
	text += "[b]Artists[/b]\n\n"
	text += "[b]Environmental Artist[/b]\n\n"
	text += "Carah Paterson\n[img=512x512]res://Textures/Credits/carah.png[/img]\n\n"

	text += "[b]Character Design[/b]\n"
	text += "[b]UI[/b]\n\n"
	text += "Niamh Mcmillan\n[img=512x512]res://Textures/Credits/niamh.png[/img]\n\n"

	text += "[b]Animation[/b]\n\n"
	text += "Lucy Doris\n[img=512x512]res://Textures/Credits/lucy.png[/img]\n\n"

	# Producer
	text += "[b]Producer[/b]\n\n"
	text += "Lee Cumming\n[img=512x512]res://Textures/Credits/lee.png[/img]\n\n"

	# Music / SFX
	text += "[b]Music/SFX[/b]\n\n"
	text += "Laurence Watt\n[img=512x512]res://Textures/Credits/laurence.png[/img]\n\n"

	# Level Design
	text += "[b]Level Design[/b]\n\n"
	text += "Kris Clark\n[img=512x512]res://Textures/Credits/kris.png[/img]\n\n[/center]"
	
	text += "[b]The Team[/b]\n"
	text += "[img=512x512]res://Textures/Credits/team.png[/img]\n\n[/center]"

	# Wait one frame so RichTextLabel calculates content height properly
	await get_tree().process_frame

	scroll_value = 0.0

	var scrollbar = get_v_scroll_bar()
	scrollbar.value = 0


func _process(delta: float) -> void:
	# Don't scroll if this node OR any parent is hidden
	if !is_visible_in_tree():
		scroll_value = 0
		return

	var scrollbar = get_v_scroll_bar()

	# Safety check in case scrollbar doesn't exist yet
	if scrollbar == null:
		return

	# Scroll upward
	scroll_value += scroll_speed * delta

	# Loop back to top when reaching bottom
	if scroll_value >= max_scroll:
		scroll_value = 0.0

	scrollbar.value = scroll_value


func _on_back_button_pressed() -> void:
	pass
