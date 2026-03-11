extends TextureButton

signal brush_selected(texture: Texture2D)

func _pressed():
	brush_selected.emit(texture_normal)
