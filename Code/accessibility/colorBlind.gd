extends ColorRect

@onready var mat := material as ShaderMaterial
@onready var mode = Global.getColorBlindMode()


func _ready() -> void:
	pass # Replace with function body.


func _process(_delta: float) -> void:
	mode = Global.getColorBlindMode()
	mat.set_shader_parameter("mode", mode)
	if mat.get_shader_parameter("mode") != 0:
		show()
	else:
		hide()
