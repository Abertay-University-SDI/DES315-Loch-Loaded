extends CanvasLayer

@export var background_old: TextureRect
@export var background_new: TextureRect
@export var anim: AnimationPlayer

var new_scene_pending: PackedScene
var new_sub: SubViewport

func _ready() -> void:
	anim.animation_finished.connect(_on_animation_finished)

func transition_to(new_scene: PackedScene) -> void:
	new_scene_pending = new_scene

	# Capture current screen into old background
	await get_tree().process_frame
	var old_image = get_viewport().get_texture().get_image()
	background_old.texture = ImageTexture.create_from_image(old_image)

	# Pre-render new scene
	var game_size = Vector2i(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height"))

	new_sub = SubViewport.new()
	new_sub.size = game_size
	new_sub.render_target_update_mode = SubViewport.UPDATE_ONCE
	new_sub.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	new_sub.add_child(new_scene.instantiate())
	add_child(new_sub)

	await get_tree().process_frame
	await get_tree().process_frame

	var new_image = new_sub.get_texture().get_image()
	background_new.texture = ImageTexture.create_from_image(new_image)

	background_old.show()
	background_new.hide()
	anim.play("transition")

func _swap_to_new_scene() -> void:
	background_old.hide()
	background_new.show()
	get_tree().change_scene_to_packed(new_scene_pending)

func _on_animation_finished(_anim_name: String) -> void:
	background_old.hide()
	background_new.hide()
	if new_sub:
		new_sub.queue_free()
		new_sub = null
