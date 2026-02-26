@tool
extends TextureRect

@export var spray_size: Vector2i = Vector2i(512, 512)
@export var brush_color:ColorPickerButton
@export var brush_slide:HSlider


@onready var popup:Popup = $Popup

const DEFAULT_PATH := "res://Saves/Spray/default.png"
const SAVED_PATH   := "res://Saves/Spray/saved.png"

var img: Image

func _ready() -> void:
	if FileAccess.file_exists(SAVED_PATH):
		set_canvas_from_path(SAVED_PATH)
	else:
		set_canvas_from_path(DEFAULT_PATH)
		

func draw_at_mouse(local_pos: Vector2) -> void:
	if img == null:
		return

	# Convert TextureRect space -> image space
	var image_pos :Vector2i= Vector2i(
		local_pos.x * img.get_width() / size.x,
		local_pos.y * img.get_height() / size.y
	)

	# Clamp inside image
	image_pos.x = clamp(image_pos.x, 0, img.get_width() - 1)
	image_pos.y = clamp(image_pos.y, 0, img.get_height() - 1)

	paint_at_pos(image_pos)
	texture.update(img)

func _gui_input(event: InputEvent) -> void:
	if img == null:
		return

	if event is InputEventMouseButton:
		if event.pressed and not event.is_echo():
			if event.button_index == MOUSE_BUTTON_LEFT:
				draw_at_mouse(event.position)
				texture.update(img)

	if event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			var lpos :Vector2= event.position

			if event.relative.length_squared() > 0:
				var steps := ceili(event.relative.length())
				var target_pos :Vector2= lpos - event.relative

				for i in steps:
					lpos = lpos.move_toward(target_pos, 1.0)
					draw_at_mouse(lpos)

			texture.update(img)




func paint_at_pos(pos: Vector2) -> void:
	img.fill_rect(Rect2i(pos,Vector2i(1,1)).grow(brush_slide.value),brush_color.color)


func clear_canvas() -> void:
	img = Image.create_empty(spray_size.x, spray_size.y, false, Image.FORMAT_RGBA8)
	texture = ImageTexture.create_from_image(img)


func set_canvas_from_path(path: String) -> void:
	var spray: Image = Image.load_from_file(path)
	spray.decompress()
	spray.resize(spray_size.x, spray_size.y, Image.INTERPOLATE_LANCZOS)

	img = spray
	texture = ImageTexture.create_from_image(img)
	
func set_canvas_from_image(path: String) -> void:
	var spray: Image = Image.load_from_file(path)
	spray.decompress()
	spray.resize(spray_size.x, spray_size.y, Image.INTERPOLATE_LANCZOS)

	img = spray
	texture = ImageTexture.create_from_image(img)


func _on_clear_button_pressed() -> void:
	clear_canvas()


func _on_default_button_pressed() -> void:
	set_canvas_from_path(DEFAULT_PATH)


func _on_save_button_pressed() -> void:
	if img == null:
		show_popup("Nothing to save.")
		return

	var result: int = img.save_png(SAVED_PATH)

	if result == OK:
		show_popup("Spray saved successfully!")
	else:
		show_popup("Failed to save spray.\nError: " + error_string(result))
	

func show_popup(message: String) -> void:
	popup.title = "Save Status"
	popup.get_node("Label").text = message
	popup.popup_centered()
	


func _on_exit_button_pressed() -> void:
	SceneTransition.transition_to_path("res://Scenes/UI/studio.tscn")
