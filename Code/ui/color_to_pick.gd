extends TextureButton

@export var color:Color =Color.RED

signal color_selected(color: Color)

func _pressed():
	color_selected.emit(color)
