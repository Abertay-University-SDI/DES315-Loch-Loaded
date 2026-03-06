extends TextureButton

@onready var _anim:AnimationPlayer=$AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_anim.play("RESET")
	grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_mouse_entered() -> void:
	_anim.play("selected")


func _on_mouse_exited() -> void:
	_anim.play("RESET")
