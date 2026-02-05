extends TextureRect

@onready var mat := material as ShaderMaterial

func _ready() -> void:
	pass # Replace with function body.

func _process(_delta):
	var mouse_screen = get_viewport().get_mouse_position()
	var screen_size = get_viewport().get_visible_rect().size

	# Convert to UV (0–1)
	var mouse_uv = mouse_screen / screen_size

	# Convert to centered UV (-0.5 → 0.5)
	mouse_uv -= Vector2(0.5, 0.5)

	mat.set_shader_parameter("var_pos", mouse_uv)
	mat.set_shader_parameter("aspect_ratio", screen_size.x / screen_size.y)
