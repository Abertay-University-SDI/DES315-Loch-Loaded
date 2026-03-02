@tool
extends MultiMeshInstance3D

## Procedural City Generator — MultiMesh Edition
## Attach to a MultiMeshInstance3D node and hit Generate in the Inspector.

@export_group("Generation")
@export var generate: bool = false:
	set(val):
		if val:
			generate = false
			_generate_city()

@export var clear: bool = false:
	set(val):
		if val:
			clear = false
			_clear_city()

@export var seed: int = 0
@export var randomize_seed: bool = false:
	set(val):
		if val:
			randomize_seed = false
			seed = randi()
			_generate_city()

@export_group("City Layout")
@export var grid_width: int = 20
@export var grid_depth: int = 20
@export var block_size: float = 4.0
@export var road_width: float = 1.5

@export_group("Building Heights")
@export var min_height: float = 1.0
@export var max_height: float = 12.0

@export_group("Building Size")
@export var min_building_scale: float = 0.6
@export var max_building_scale: float = 0.95

@export_group("Density")
@export_range(0.0, 1.0) var density: float = 0.85

@export_group("District Zones")
@export var downtown_radius: float = 5.0
@export var suburb_falloff: float = 8.0

@export_group("Setback Rooftops")
## Chance a building gets a smaller stacked block on top
@export_range(0.0, 1.0) var rooftop_chance: float = 0.35
@export var rooftop_min_scale: float = 0.35
@export var rooftop_max_scale: float = 0.65
@export var rooftop_height_fraction: float = 0.25

@export_group("Visual")
@export var base_color: Color = Color(0.25, 0.27, 0.32)
@export var accent_color: Color = Color(0.55, 0.58, 0.65)
@export var rooftop_lighten: float = 0.12

var _rng := RandomNumberGenerator.new()


func _generate_city() -> void:
	_clear_city()
	_rng.seed = seed

	var half_w := grid_width * 0.5
	var half_d := grid_depth * 0.5
	var step   := block_size + road_width

	# ---- First pass: collect all instance data -------------------------
	var transforms: Array[Transform3D] = []

	for gx in range(grid_width):
		for gz in range(grid_depth):
			if _rng.randf() > density:
				continue

			var cx := (gx - half_w) * step + block_size * 0.5
			var cz := (gz - half_d*2) * step + block_size * 0.5

			# District height multiplier
			var dist := Vector2(cx, cz).length()
			var t    :float= clamp((dist - downtown_radius) / max(suburb_falloff, 0.01), 0.0, 1.0)
			var dmul :float= lerp(1.0, 0.25, t)

			var bw := _rng.randf_range(min_building_scale, max_building_scale) * block_size
			var bd := _rng.randf_range(min_building_scale, max_building_scale) * block_size
			var bh :float= max(_rng.randf_range(min_height, max_height) * dmul, 0.5)

			var ox := _rng.randf_range(-(block_size - bw) * 0.5, (block_size - bw) * 0.5)
			var oz := _rng.randf_range(-(block_size - bd) * 0.5, (block_size - bd) * 0.5)

			# Main building — scale X/Z for footprint, Y for height
			# Unit cube is centred at origin spanning -0.5..0.5 on each axis,
			# so we translate Y by bh*0.5 to sit on the ground plane.
			var t_main := Transform3D(
				Basis(
					Vector3(bw, 0, 0),
					Vector3(0, bh, 0),
					Vector3(0, 0, bd)
				),
				Vector3(cx + ox, bh * 0.5, cz + oz)
			)
			transforms.append(t_main)

			# Setback rooftop block
			if _rng.randf() < rooftop_chance and bh > 3.0:
				var tw := bw * _rng.randf_range(rooftop_min_scale, rooftop_max_scale)
				var td := bd * _rng.randf_range(rooftop_min_scale, rooftop_max_scale)
				var th := bh * rooftop_height_fraction

				var t_top := Transform3D(
					Basis(
						Vector3(tw, 0, 0),
						Vector3(0, th, 0),
						Vector3(0, 0, td)
					),
					Vector3(cx + ox, bh + th * 0.5, cz + oz)
				)
				transforms.append(t_top)

	# ---- Build MultiMesh -----------------------------------------------
	var mm := MultiMesh.new()
	mm.transform_format   = MultiMesh.TRANSFORM_3D
	mm.instance_count     = transforms.size()
	mm.mesh               = _make_unit_cube()

	for i in transforms.size():
		mm.set_instance_transform(i, transforms[i])

	multimesh = mm

	# ---- Material ---------------------------------------------------------
	var mat := StandardMaterial3D.new()
	mat.roughness = 0.85
	mat.metallic  = 0.05
	mm.mesh.surface_set_material(0, mat)

	print("[ProceduralCity] Seed %d — %d instances generated." % [seed, transforms.size()])


func _make_unit_cube() -> ArrayMesh:
	## Returns a unit cube centred at origin (each axis -0.5 to 0.5).
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	# 8 corners of unit cube
	var v := [
		Vector3(-0.5, -0.5, -0.5),  # 0
		Vector3( 0.5, -0.5, -0.5),  # 1
		Vector3( 0.5, -0.5,  0.5),  # 2
		Vector3(-0.5, -0.5,  0.5),  # 3
		Vector3(-0.5,  0.5, -0.5),  # 4
		Vector3( 0.5,  0.5, -0.5),  # 5
		Vector3( 0.5,  0.5,  0.5),  # 6
		Vector3(-0.5,  0.5,  0.5),  # 7
	]

	# Top
	_quad(st, v[5], v[4], v[7], v[6])
	# Front  (-Z)
	_quad(st, v[1], v[0], v[4], v[5])
	# Back   (+Z)
	_quad(st, v[3], v[2], v[6], v[7])
	# Left   (-X)
	_quad(st, v[0], v[3], v[7], v[4])
	# Right  (+X)
	_quad(st, v[2], v[1], v[5], v[6])
	# Bottom (kept so shadow casters work correctly)
	_quad(st, v[0], v[1], v[2], v[3])

	st.generate_normals()
	return st.commit()


func _quad(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3) -> void:
	st.add_vertex(a)
	st.add_vertex(c)
	st.add_vertex(b)
	st.add_vertex(c)
	st.add_vertex(a)
	st.add_vertex(d)


func _clear_city() -> void:
	multimesh = null
