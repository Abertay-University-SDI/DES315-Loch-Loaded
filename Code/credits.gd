extends RichTextLabel

@export var scroll_speed: float = 56.1  # pixels per second
var scroll_value: float = 0.0

func _ready() -> void:
	bbcode_enabled = true
	
	text = "\n\n\n\n\n\n"
	
	# Programmers
	text += "[center][b]Programmers[/b]\n\n"
	text += "Peter Mazanik\n[img=300x600]res://credits_images/peter.png[/img]\n\n"
	text += "Andrew Moore\n[img=64x64]res://credits_images/andrew.png[/img]\n\n"
	
	# Artists
	text += "[b]Artists[/b]\n\n"
	text += "Niamh Mcmillan\n[img=64x64]res://credits_images/niamh.png[/img]\n\n"
	text += "Lucy Doris\n[img=64x64]res://credits_images/lucy.png[/img]\n\n"
	text += "Carah Paterson\n[img=64x64]res://credits_images/carah.png[/img]\n\n"
	
	# Producer
	text += "[b]Producer[/b]\n\n"
	text += "Lee Cumming\n[img=64x64]res://credits_images/lee.png[/img]\n\n"
	
	# Music / SFX
	text += "[b]Music/SFX[/b]\n\n"
	text += "Laurence Watt\n[img=64x64]res://credits_images/laurence.png[/img]\n\n"
	
	# Level Design
	text += "[b]Level Design[/b]\n\n"
	text += "Kris Clark\n[img=64x64]res://credits_images/kris.png[/img]\n\n[/center]"

	get_v_scroll_bar().value = 0

func _process(delta: float) -> void:
	if visible:
		scroll_value += scroll_speed * delta
		get_v_scroll_bar().value = scroll_value
