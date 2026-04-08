@tool
extends TextureButton

@export var label_text:String

@onready var anim: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	var label = get_node_or_null("Label")
	if label != null:
		label.text = label_text
	focus_mode = Control.FOCUS_ALL
	
	connect("mouse_entered", Callable(self, "_on_hover_start"))
	connect("mouse_exited", Callable(self, "_on_hover_end"))
	connect("focus_entered", Callable(self, "_on_hover_start"))
	connect("focus_exited", Callable(self, "_on_hover_end"))

func _on_hover_start() -> void:
	anim.play("hover")

func _on_hover_end() -> void:
	anim.play("hover_end")
