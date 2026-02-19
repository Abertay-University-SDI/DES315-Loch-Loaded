extends GPUParticles2D

const DEFAULT_PATH := "res://Saves/Spray/default.png"
const SAVED_PATH   := "res://Saves/Spray/saved.png"

@export var spray: Sprite2D

func _ready() -> void:
	var shader_texture: Texture2D
	
	if FileAccess.file_exists(SAVED_PATH):
		shader_texture = ImageTexture.create_from_image(Image.load_from_file(SAVED_PATH))
	else:
		shader_texture = ImageTexture.create_from_image(Image.load_from_file(DEFAULT_PATH))

	#has to be process material and not shader material
	var mat := process_material
	if mat is ShaderMaterial:
		mat.set_shader_parameter("sprite", shader_texture)

	spray.texture = shader_texture
