extends GPUParticles2D

const SAVED_PATH   := "user://RadicalRampage/Saves/Spray/saved.png"
@export var default_texture:TextureRect

@export var spray: Sprite2D

func _ready() -> void:
	var shader_texture: Texture2D
	
	if FileAccess.file_exists(SAVED_PATH):
		shader_texture = ImageTexture.create_from_image(Image.load_from_file(SAVED_PATH))
	else:
		shader_texture = ImageTexture.create_from_image(default_texture.texture.get_image())

	#has to be process material and not shader material
	var mat := process_material
	if mat is ShaderMaterial:
		mat.set_shader_parameter("sprite", shader_texture)

	spray.texture = shader_texture
