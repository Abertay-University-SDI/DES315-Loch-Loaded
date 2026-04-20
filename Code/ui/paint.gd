@tool
extends TextureRect

@export var spray_size: Vector2i = Vector2i(512, 512)
@export var brush_color:ColorPicker
@export var brush_slide:HSlider

@export var default_image_texture:TextureRect

@onready var popup:Popup = $Popup

@export var brush_grid: GridContainer

var brush_texture: Texture2D
var brush_img: Image

var cached_stamp: Image
var cached_size: int = -1
var cached_color: Color

const SAVED_PATH   := "user://RadicalRampage/Saves/Spray/saved.png"

var img: Image
var current_color:Color

const ERASER_COLOR:Color=Color(0,0,0,0)


var updated_brush:bool = false

func _on_brush_selected(tex: Texture2D):
	brush_texture = tex
	brush_img = tex.get_image()
	updated_brush = true

func _ready() -> void:
	var first = brush_grid.get_child(0)
	if first and first.has_method("_pressed"):
		_on_brush_selected(first.texture_normal)
	for button in brush_grid.get_children():
		if button.has_signal("brush_selected"):
			button.brush_selected.connect(_on_brush_selected)
		
	var dir = DirAccess.open("user://")
	if dir:
		var err = dir.make_dir_recursive("user://RadicalRampage/Saves/Spray/")
		if err == OK:
			print("Directories created successfully!")
		else:
			print("Failed to create directories. Error code:", err)
			
	if FileAccess.file_exists(SAVED_PATH):
		set_canvas_from_path(SAVED_PATH)
	else:
		set_canvas_from_image()
		

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
				current_color = brush_color.color
			else:
				current_color = ERASER_COLOR
				
			if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT:
				draw_at_mouse(event.position)
				texture.update(img)

	if event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT or  event.button_mask & MOUSE_BUTTON_MASK_RIGHT:
			var lpos :Vector2= event.position

			if event.relative.length_squared() > 0:
				var steps := ceili(event.relative.length())
				var target_pos :Vector2= lpos - event.relative

				for i in steps:
					lpos = lpos.move_toward(target_pos, 1.0)
					draw_at_mouse(lpos)

			texture.update(img)



func rebuild_stamp():
	if brush_img == null:
		return

	var size := int(brush_slide.value)

	if cached_stamp \
	and size == cached_size \
	and cached_color == current_color\
	and updated_brush == false:
		return


	updated_brush = false
	cached_size = size
	cached_color = current_color

	var stamp := brush_img.duplicate()
	stamp.resize(size, size, Image.INTERPOLATE_NEAREST)

	var s :Vector2i= stamp.get_size()

	for y in s.y:
		for x in s.x:
			var c :Color= stamp.get_pixel(x, y)
			var alpha := c.a * current_color.a

			stamp.set_pixel(
				x, y,
				Color(
					current_color.r,
					current_color.g,
					current_color.b,
					alpha
				)
			)

	cached_stamp = stamp

func paint_at_pos(pos: Vector2i) -> void:
	if brush_img == null:
		return

	rebuild_stamp()

	var stamp_size := cached_stamp.get_size()
	var offset: Vector2i = pos - stamp_size / 2

	if current_color == ERASER_COLOR:
		img.blit_rect(
			cached_stamp,
			Rect2i(Vector2i.ZERO, stamp_size),
			offset
		)
	else:
		img.blend_rect(
			cached_stamp,
			Rect2i(Vector2i.ZERO, stamp_size),
			offset
		)


func clear_canvas() -> void:
	img = Image.create_empty(spray_size.x, spray_size.y, false, Image.FORMAT_RGBA8)
	texture = ImageTexture.create_from_image(img)


func set_canvas_from_path(path: String) -> void:
	var spray: Image = Image.load_from_file(path)
	spray.decompress()
	spray.resize(spray_size.x, spray_size.y, Image.INTERPOLATE_LANCZOS)

	img = spray
	texture = ImageTexture.create_from_image(img)
	
func set_canvas_from_image() -> void:
	var spray: Image = default_image_texture.texture.get_image()
	spray.decompress()
	spray.resize(spray_size.x, spray_size.y, Image.INTERPOLATE_LANCZOS)

	img = spray
	texture = ImageTexture.create_from_image(img)


func _on_clear_button_pressed() -> void:
	clear_canvas()


func _on_default_button_pressed() -> void:
	set_canvas_from_image()


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
