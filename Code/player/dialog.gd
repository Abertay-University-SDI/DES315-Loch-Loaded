@tool
extends NinePatchRect
@export var text_box: RichTextLabel
@export var anim: AnimationPlayer
@export var chars_per_second: float = 30.0

var dialog_lines: Array = []
var current_line: int = 0
var current_speaker: String = ""
var tween: Tween


func _play_current_line() -> void:
	text_box.text = "[b]%s[/b]\n%s" % [current_speaker, dialog_lines[current_line]]
	var speaker_chars = current_speaker.length() + 7  # skip [b][/b]\n
	var total_chars = text_box.get_total_character_count()
	var duration = (total_chars - speaker_chars) / chars_per_second
	
	text_box.visible_characters = speaker_chars
	
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(text_box, "visible_characters", total_chars, duration)

func show_dialog(dialog_id: String) -> void:
	var file = FileAccess.open("res://dialog.json", FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	var entry = data[dialog_id]
	current_speaker = entry["speaker"]
	dialog_lines = entry["lines"]
	current_line = 0
	show()
	_play_current_line()

func _ready() -> void:
	show_dialog("surfer_dude_intro")

func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") && visible:
		if tween && tween.is_running():
			# skip to end
			tween.kill()
			text_box.visible_characters = -1
		else:
			current_line += 1
			if current_line < dialog_lines.size():
				_play_current_line()
			else:
				get_parent().hide()

func _on_visibility_changed() -> void:
	if visible:
		show_dialog("surfer_dude_intro")
		_play_current_line()
