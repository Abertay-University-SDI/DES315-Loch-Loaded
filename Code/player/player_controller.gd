class_name Player
extends CharacterBody2D

signal health_changed(health: float)

@export var play_area: Area2D
@export var play_area_shape: CollisionShape2D

@export var footstep_sfx: AudioStreamPlayer2D
@export var dash_sfx: AudioStreamPlayer2D
@export var punch_sfx: AudioStreamPlayer2D

@export var yoyo: Sprite2D
@export var yoyo_string: Line2D

@export var spawn: Marker2D

var _camera: Camera2D
var _anim: AnimatedSprite2D
var _move_particles: GPUParticles2D
var _dash_particles: GPUParticles2D

var _spray_scene: PackedScene
var _attack_area: Area2D
var _dash_attack_area: Area2D

const MAX_SPEED := 150.0
const TIME_TO_MAX := 0.4
const ACCEL := MAX_SPEED / TIME_TO_MAX
const FRICTION := 600.0
const JUMP_VELOCITY := -400.0

const MAX_HEALTH := 100.0
var health_value := MAX_HEALTH

const MAX_JUMPS := 1
var jumps_left := MAX_JUMPS

const DASH_COOLDOWN := 1.0
const DASH_DURATION := 0.2

var dash_timer := 0.0
var dashing := false

var spraying := false
var punching := 0.0

var _gravity: float
var _breaking := false

var _yoyo_returning := false
var _yoyo_timer := 0.0
var _yoyo_duration := 1.0
var last_hit_position := Vector2.ZERO
var yoyo_enemy: Robot = null
var yoyo_enemy_body: CharacterBody2D = null

var dir_radial := Vector2.ZERO


func _ready() -> void:
	_camera = $Camera2D
	_anim = $AnimatedSprite2D
	_move_particles = $GPUParticles2D
	_dash_particles = $dash_sfx

	_attack_area = $attack_area
	_dash_attack_area = $dash_attack_area

	_attack_area.body_entered.connect(_on_body_entered)
	_dash_attack_area.body_entered.connect(_on_dash_body_hit)

	_attack_area.monitoring = false
	_dash_attack_area.monitoring = false

	_spray_scene = load("res://Scenes/Interactables/spray.tscn")
	_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

	play_area.body_exited.connect(_respawn_player)

	_setup_camera_limits()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("spray"):
		spraying = true
		_anim.play("Paint")
		return

	if event.is_action_pressed("punch"):
		punching = 0.4
		punch_sfx.play()
		_attack_area.monitoring = true

	if event.is_action_pressed("dash") and dash_timer < 0.0:
		_start_dash()

	if event.is_action_pressed("yoyo") and yoyo.visible and is_instance_valid(yoyo_enemy):
		print("Yoyo hit!")
		print(yoyo_enemy)
		var dir := (yoyo_enemy.position - position).normalized()
		dir += Vector2.DOWN
		yoyo_enemy.take_hit(-dir, -0.1, 100.0)


func _process(delta: float) -> void:
	if health_value < 0:
		_respawn_player(self)
		
	emit_signal("health_changed", health_value)
	_update_cooldowns(delta)
	_update_yoyo()


func _physics_process(delta: float) -> void:
	if dash_timer < DASH_COOLDOWN - DASH_DURATION:
		dashing = false

	if is_on_floor():
		jumps_left = MAX_JUMPS

	_apply_gravity(delta)
	_handle_jump()
	_handle_movement(delta)

	_update_attack_offset()
	_update_animation()

	move_and_slide()


func _respawn_player(body: Node) -> void:
	if body != self:
		return
	health_value = MAX_HEALTH
	global_position = spawn.global_position


func _apply_gravity(dt: float) -> void:
	if not is_on_floor() and not dashing:
		velocity += Vector2.DOWN * _gravity * dt

	if is_on_wall() and not is_on_floor() and velocity.y > 0:
		var damp := 1.2 if dir_radial.y > 0 else 0.2
		velocity = Vector2.DOWN * _gravity * dt * damp
		jumps_left = MAX_JUMPS


func _handle_jump() -> void:
	if not Input.is_action_just_pressed("jump") or jumps_left <= 0 or dashing:
		return

	velocity = Vector2(velocity.x, JUMP_VELOCITY)
	jumps_left -= 1

	if is_on_wall_only():
		velocity = (Vector2(get_wall_normal().x * 400.0, JUMP_VELOCITY / 2.0) + velocity) * 0.5


func _handle_movement(dt: float) -> void:
	dir_radial = Vector2(Input.get_axis("left", "right"), Input.get_axis("jump", "down"))
	_breaking = sign(dir_radial.x) != sign(velocity.x) and dir_radial.x != 0

	if dir_radial.x != 0:
		var target := dir_radial.x * MAX_SPEED
		var accel := ACCEL * dt * (2.0 if _breaking else 1.0)

		velocity = Vector2(
			move_toward(velocity.x, target, accel),
			velocity.y
		)

		_anim.flip_h = dir_radial.x < 0

		var mat := _move_particles.process_material as ParticleProcessMaterial
		if mat:
			mat.direction = Vector3(sign(-dir_radial.x), -0.3, 0)
	else:
		velocity = Vector2(
			move_toward(velocity.x, 0.0, FRICTION * dt),
			velocity.y
		)

	if dir_radial.y > 0.0:
		set_collision_mask_value(2, false)
	else:
		set_collision_mask_value(2, true)


func _start_dash() -> void:
	dashing = true
	dash_timer = DASH_COOLDOWN

	var dir := Vector2(-1 if _anim.flip_h else 1, 0)
	velocity = dir * 400.0

	_dash_particles.emitting = true
	_dash_attack_area.monitoring = true
	dash_sfx.play()


func _update_cooldowns(dt: float) -> void:
	if punching > 0.0:
		punching -= dt
		if punching <= 0.0:
			_attack_area.monitoring = false

	if dash_timer >= 0.0:
		dash_timer -= dt

		if dash_timer < DASH_COOLDOWN - DASH_DURATION:
			dashing = false
			var mat := _dash_particles.process_material as ShaderMaterial
			if mat:
				mat.set_shader_parameter("fliph", _anim.flip_h)
			_dash_attack_area.monitoring = false
			_dash_particles.emitting = false


func _update_animation() -> void:
	if spraying:
		if _anim.animation != "Paint" or not _anim.is_playing():
			spraying = false
		else:
			return

	var speed := absf(velocity.x)

	if dashing:
		_anim.play("Dash")
	elif is_on_wall() and not is_on_floor():
		_anim.play("Wall")
	elif not is_on_floor():
		_anim.play("Jump")
	elif punching > 0.0:
		_anim.play("Punch")
	elif _breaking and speed > 100.0:
		_anim.play("Breaking")
		_move_particles.emitting = true
	elif speed < 5.0:
		_anim.play("Idle")
		_move_particles.emitting = false
	else:
		_anim.play("Walk")
		_move_particles.emitting = false
		if not footstep_sfx.playing and randf() < 0.2:
			footstep_sfx.play()


func _update_yoyo() -> void:
	if not yoyo.visible:
		return

	var dt := get_process_delta_time()

	if not _yoyo_returning:
		_yoyo_timer -= dt

		if is_instance_valid(yoyo_enemy_body):
			var hit := yoyo_enemy_body.global_position
			hit.y -= 16
			yoyo.global_position = hit

		if _yoyo_timer <= 0.0:
			_yoyo_returning = true
	else:
		var target := global_position
		target.y -= 10

		yoyo.global_position = yoyo.global_position.move_toward(target, 300.0 * dt)

		if yoyo.global_position.distance_to(target) < 5.0:
			yoyo.visible = false
			_yoyo_returning = false
			yoyo_enemy = null
			yoyo_enemy_body = null

	var player_local := yoyo_string.to_local(global_position)
	player_local.y -= 10

	var yoyo_local := yoyo_string.to_local(yoyo.global_position)

	yoyo_string.set_point_position(0, player_local)
	yoyo_string.set_point_position(1, yoyo_local)


func _update_attack_offset() -> void:
	var offset := _attack_area.position
	offset.x = -absf(offset.x) if _anim.flip_h else absf(offset.x)
	_attack_area.position = offset


func _on_body_entered(body: Node) -> void:
	var enemy := body.get_parent()
	if not enemy is Robot or not enemy.is_in_group("Enemy"):
		return

	var dir :Vector2= (enemy.global_position - global_position).normalized()
	enemy.take_hit(dir, punching, 100.0)


func _on_dash_body_hit(body: Node) -> void:
	var enemy := body.get_parent()
	if not enemy is Robot or not enemy.is_in_group("Enemy"):
		return

	var hit := (body as Node2D).global_position
	hit.y -= 16

	last_hit_position = hit
	yoyo_enemy = enemy
	yoyo_enemy_body = body as CharacterBody2D
	yoyo.visible = true

	_yoyo_timer = _yoyo_duration
	_yoyo_returning = false

	enemy.take_dash(dash_timer, 400.0)


func _setup_camera_limits() -> void:
	if play_area == null or play_area_shape == null:
		push_error("Play area or play area shape not assigned!")
		return

	var shape := play_area_shape.shape

	if shape is RectangleShape2D:
		var shape_size: Vector2 = shape.size
		var area_position := play_area.global_position
		var shape_position := play_area_shape.global_position

		var top_left := area_position + shape_position - (shape_size / 2)
		var bottom_right := area_position + shape_position + (shape_size / 2)

		_camera.limit_left = int(top_left.x)
		_camera.limit_top = int(top_left.y)
		_camera.limit_right = int(bottom_right.x)
		_camera.limit_bottom = int(bottom_right.y)

		_camera.limit_smoothed = true

		print("Camera limits set: Left=%d, Top=%d, Right=%d, Bottom=%d" % [
			_camera.limit_left, _camera.limit_top,
			_camera.limit_right, _camera.limit_bottom
		])
	else:
		push_error("Play area shape is not a RectangleShape2D!")
