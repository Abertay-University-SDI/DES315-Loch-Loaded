extends Label

const MAGNITUDE : int = 6
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var dir = mouse_pos-position
	dir = dir.normalized()
	add_theme_constant_override("shadow_offset_x",(dir*MAGNITUDE).x)
	add_theme_constant_override("shadow_offset_y",(dir*MAGNITUDE).y)
	
