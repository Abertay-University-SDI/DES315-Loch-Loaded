@tool
extends TextureButton

@export var label_text: String

@export var buttonHover: AudioStreamPlayer2D
@export var buttonPress: AudioStreamPlayer2D

@onready var anim: AnimationPlayer = $AnimationPlayer

var is_hovered := false


func _ready() -> void:
	var label = get_node_or_null("Label")
	if label != null:
		label.text = label_text

	focus_mode = Control.FOCUS_ALL

	mouse_entered.connect(_on_hover_start)
	mouse_exited.connect(_on_hover_end)
	focus_entered.connect(_on_hover_start)
	focus_exited.connect(_on_hover_end)


func _on_hover_start() -> void:
	if is_hovered:
		return

	is_hovered = true

	if buttonHover:
		buttonHover.play()

	anim.play("hover")


func _on_hover_end() -> void:
	if !is_hovered:
		return

	is_hovered = false
	anim.play("hover_end")


func _on_pressed() -> void:
	if buttonPress:
		buttonPress.play()
