@tool
extends NinePatchRect

@export var text_box:RichTextLabel
@export var anim:AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text_box.text = "[b]Surfer Dude[/b]\n"
	text_box.text+= "Yoo, im the surfer dude yeah, wassup cuh hows it going you see that sick ahh tower over there how about making it even more sick, go get em champ"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if !anim.is_playing() && visible:
			hide()
		else:
			anim.speed_scale = 10.0

func _on_visibility_changed() -> void:
	if visible:
		anim.speed_scale = 1
		anim.play("draw_text")
