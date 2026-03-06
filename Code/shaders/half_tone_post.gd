extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _process(_delta):
	var size = get_viewport().get_visible_rect().size
	material.set_shader_parameter("viewport_size", size)
