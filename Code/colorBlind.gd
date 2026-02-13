extends ColorRect

@onready var mat := material as ShaderMaterial

func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	if mat.get_shader_parameter("mode") == 0:
		hide()
	else:
		show()
