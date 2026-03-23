class_name Player
extends CharacterBody2D

signal health_changed(health: float)

@export_group("World")
@export var play_area: Area2D
@export var play_area_shape: CollisionShape2D
@export var spawn: Marker2D
@export var level_end_area : Area2D
@export var levelEndScene : Control

@export_group("Detectors")
@export var zipline_detector:Area2D
@export var crane_detector:Area2D
@export var yoyo_detector:Area2D

@export_group("SFX")
@export var footstep_sfx: AudioStreamPlayer2D
@export var dash_sfx: AudioStreamPlayer2D
@export var punch_sfx: AudioStreamPlayer2D
@export var YoYo_sfx: AudioStreamPlayer2D

@export_group("yoyo")
@export var yoyo: Sprite2D
@export var yoyo_string: Line2D

@export_group("player_Colision")
@export var idle_collider:CollisionShape2D

@onready var top_ray:RayCast2D=$top_ray
@onready var bottom_ray:RayCast2D=$bottom_ray

@onready var anim_player:AnimationPlayer=$AnimationPlayer

@onready var stun_attack_area:Area2D=$stun_area
const STUN_TIME:float=3.3

var _prev_health := MAX_HEALTH
var _player_material: ShaderMaterial
var damage_effect_time:float =0.2
var time_since_damage:float = 0.0

var _camera: Camera2D
var _anim: AnimatedSprite2D
var _dash_particles: GPUParticles2D

var _spray_scene: PackedScene
var _attack_area: Area2D
var _dash_attack_area: Area2D

const MAX_SPEED := 180.0
const TIME_TO_MAX := 0.4
const ACCEL := MAX_SPEED / TIME_TO_MAX
const FRICTION := 600.0
const JUMP_VELOCITY := -400.0

# --- Variable jump height ---
const JUMP_CUT_MULTIPLIER := 0.4

const MAX_HEALTH := 100.0
var health_value := MAX_HEALTH

const MAX_JUMPS := 2
var jumps_left := MAX_JUMPS

# --- Coyote time ---
const COYOTE_TIME := 0.22
var _coyote_timer := 0.0
var _was_on_floor := false

# --- Jump buffer ---
const JUMP_BUFFER_TIME := 0.1
var _jump_buffer_timer := 0.0

const DASH_COOLDOWN := 1.0
const DASH_DURATION := 0.2

var dash_timer := 0.0
var dashing := false

var spraying := false
var punching := 0.0

var _gravity: float
var _breaking := false
var _on_zipline:bool
var _on_crane:bool
var _in_crane_area: bool
var zipping:bool

var zipline_dir:Vector2
var crane_dir:Vector2
var crane_point:Vector2


# --- Crouch / Slide ---
var crouching := false
var sliding := false
const SLIDE_SPEED := 280.0
const SLIDE_FRICTION := 180.0
const SLIDE_MIN_SPEED := 30.0
const CROUCH_SPEED_MULT := 0.5
var _slide_dir := 1.0

# --- Yoyo ---
var _yoyo_returning := false
var _yoyo_timer := 0.0
var _yoyo_duration := 1.0
var last_hit_position := Vector2.ZERO
var yoyo_enemy: Enemy = null
var yoyo_enemy_body: CharacterBody2D = null

var dir_radial := Vector2.ZERO

var is_dying :bool=false

func _ready() -> void:
	_camera = $Camera2D
	_anim = $AnimatedSprite2D
	_dash_particles = $dash_sfx

	_attack_area = $attack_area
	_dash_attack_area = $dash_attack_area

	_player_material = _anim.material as ShaderMaterial

	_attack_area.body_entered.connect(_on_body_entered)
	_dash_attack_area.body_entered.connect(_on_dash_body_hit)

	_attack_area.monitoring = false
	_dash_attack_area.monitoring = false

	_spray_scene = load("res://Scenes/Interactables/spray.tscn")
	_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

	play_area.body_exited.connect(_respawn_player)
	level_end_area.body_entered.connect(_end_level)
	
	zipline_detector.body_entered.connect(zip_entered)
	zipline_detector.body_exited.connect(zip_exited)
	
	crane_detector.body_entered.connect(crane_entered)
	crane_detector.body_exited.connect(crane_exited)
	
	yoyo_detector.body_entered.connect(yoyo_entered)

	stun_attack_area.body_entered.connect(_on_stun_body_entered)
	stun_attack_area.monitoring = false

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

	# Buffer jump input so pressing just before landing still jumps
	if event.is_action_pressed("jump"):
		_jump_buffer_timer = JUMP_BUFFER_TIME

	# Variable jump height — cut velocity when jump released early
	if event.is_action_released("jump") and velocity.y < 0:
		velocity.y *= JUMP_CUT_MULTIPLIER

	if event.is_action_pressed("stun"):
		stun_attack_area.monitoring = true
		if _player_material:
			_player_material.set_shader_parameter("stunning", true)
		await get_tree().create_timer(0.2).timeout
		if _player_material:
			_player_material.set_shader_parameter("stunning", false)
		stun_attack_area.monitoring = false

	if event.is_action_pressed("yoyo"):
		if (yoyo.visible and is_instance_valid(yoyo_enemy)):
			var dir := (yoyo_enemy.position - position).normalized()
			if (yoyo_enemy._alive.is_on_floor()):
				dir *= 3
			else:
				dir += Vector2.DOWN * -3
			YoYo_sfx.play()
			yoyo_enemy.take_hit(-dir, -0.1, 100.0, 30)
		elif (_in_crane_area):
			_on_crane = true
		elif (yoyo.visible == false):
			_throw_yoyo()
		else:
			return
			


	# Crouch input — only on floor and not dashing
	if event.is_action_pressed("crouch") and is_on_floor() and not dashing:
		_try_start_crouch_or_slide(event)

	if event.is_action_released("crouch"):
		_end_crouch()


func _process(delta: float) -> void:
	if health_value < 0:
		_respawn_player(self)

	# detect damage
	if health_value < _prev_health:
		if _player_material:
			_player_material.set_shader_parameter("taking_damage", true)
			time_since_damage = 0.0
	if time_since_damage>damage_effect_time:
		if _player_material:
			_player_material.set_shader_parameter("taking_damage", false)

	time_since_damage+= delta
	_prev_health = health_value

	emit_signal("health_changed", health_value)
	_update_cooldowns(delta)
	_update_yoyo()


func _physics_process(delta: float) -> void:
	if dash_timer < DASH_COOLDOWN - DASH_DURATION:
		dashing = false

	# Coyote time tracking
	if is_on_floor() || is_on_wall():
		jumps_left = MAX_JUMPS
		_coyote_timer = COYOTE_TIME
		_was_on_floor = true
	else:
		if _was_on_floor:
			_coyote_timer -= delta
			if _coyote_timer <= 0.0:
				_was_on_floor = false
				if jumps_left == MAX_JUMPS:
					jumps_left -= 1

	_update_wall_rays()
	_apply_gravity(delta)
	_handle_jump()
	_handle_movement(delta)

	_update_attack_offset()
	_update_animation()

	move_and_slide()

	# End slide if nearly stopped or left the floor
	if sliding and (absf(velocity.x) < SLIDE_MIN_SPEED or not is_on_floor()):
		_end_slide()


# ─── Crouch / Slide helpers ──────────────────────────────────────────────────

func _try_start_crouch_or_slide(event: InputEvent) -> void:
	var speed := absf(velocity.x)
	if speed > 60.0:
		_start_slide()
	else:
		crouching = true
	if (event is InputEventJoypadMotion):
		var input_vec: Vector2 = Vector2( 
			Input.get_joy_axis(0, JOY_AXIS_LEFT_X), 
			Input.get_joy_axis(0, JOY_AXIS_LEFT_Y))
		if (rad_to_deg(input_vec.angle()) > 89 and rad_to_deg(input_vec.angle()) < 91):
			set_collision_mask_value(2, false)
	idle_collider.set_deferred("disabled",true)


func _start_slide() -> void:
	sliding = true
	crouching = false
	_slide_dir = sign(velocity.x) if velocity.x != 0.0 else (-1.0 if _anim.flip_h else 1.0)
	velocity.x = _slide_dir * max(absf(velocity.x), SLIDE_SPEED)


func _end_slide() -> void:
	sliding = false


func _has_headroom() -> bool:
	var space_state = get_world_2d().direct_space_state

	var params := PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + Vector2.UP * 32
	)

	params.exclude = [self]

	var result = space_state.intersect_ray(params)

	return result.is_empty()
	
func _end_crouch() -> void:
	if not _has_headroom():
		return

	crouching = false
	sliding = false
	set_collision_mask_value(2, true)
	idle_collider.set_deferred("disabled", false)


# ─── Core movement ───────────────────────────────────────────────────────────
func _update_wall_rays():
	var dir = -1 if _anim.flip_h else 1
	top_ray.target_position.x = 11 * dir
	bottom_ray.target_position.x = 11 * dir
	
func _respawn_player(body: Node) -> void:
	if is_dying or body != self:
		return
	is_dying = true
	SceneTransition.death_reset()


func _apply_gravity(dt: float) -> void:
	if not is_on_floor() and not dashing and not zipping:
		var grav_mult := 1.5 if velocity.y > 0 else 1.0
		velocity += Vector2.DOWN * _gravity * grav_mult * dt

	if _is_touching_wall_full() and not is_on_floor() and velocity.y > 0 and not crouching:
		var damp := 3.2 if dir_radial.y > 0 else 1.2
		velocity = Vector2.DOWN * _gravity * dt * damp
		jumps_left = MAX_JUMPS

func _is_touching_wall_full() -> bool:
	return top_ray.is_colliding() and bottom_ray.is_colliding()


func _handle_jump() -> void:
	if _jump_buffer_timer > 0.0:
		_jump_buffer_timer -= get_physics_process_delta_time()


	var can_jump := (is_on_floor() or _coyote_timer > 0.0) or (jumps_left > 0 and jumps_left < MAX_JUMPS)
	if not (_jump_buffer_timer > 0.0 and can_jump) or dashing:
		return

	_end_crouch()

	_jump_buffer_timer = 0.0
	velocity = Vector2(velocity.x, JUMP_VELOCITY)
	jumps_left -= 1
	_coyote_timer = 0.0

	if is_on_wall_only():
		velocity = (Vector2(get_wall_normal().x * 400.0, JUMP_VELOCITY / 2.0) + velocity) * 0.5


func _handle_movement(dt: float) -> void:
	
	
	dir_radial = Vector2(Input.get_axis("left", "right"), Input.get_axis("jump", "down"))
	_breaking = sign(dir_radial.x) != sign(velocity.x) and dir_radial.x != 0

	if dir_radial.y<=0.0 && _on_zipline && velocity.y>0:
		zipping = true
		velocity.x = zipline_dir.x*400.0
		velocity.y = zipline_dir.y*400.0
		return
	zipping = false
	
		
	if _on_crane:
		calculate_crane_dir()
		velocity = crane_dir * 5.0
		print_debug(global_position.distance_to(crane_point))
		if (global_position.distance_to(crane_point) <= 50):
			_on_crane = false
			velocity = crane_dir * 10.0
		# crane todo

	if sliding:
		velocity.x = move_toward(velocity.x, 0.0, SLIDE_FRICTION * dt)
		_anim.flip_h = _slide_dir < 0
		return

	if dir_radial.x != 0:
		var speed_cap := MAX_SPEED * (CROUCH_SPEED_MULT if crouching else 1.0)
		var target := dir_radial.x * speed_cap
		var accel := ACCEL * dt * (2.0 if _breaking else 1.0)

		velocity = Vector2(
			move_toward(velocity.x, target, accel),
			velocity.y
		)

		_anim.flip_h = dir_radial.x < 0
	else:
		velocity = Vector2(
			move_toward(velocity.x, 0.0, FRICTION * dt),
			velocity.y
		)

	if dir_radial.y > 0.0 and not crouching:
		set_collision_mask_value(2, false)
	elif not crouching:
		set_collision_mask_value(2, true)


func _start_dash() -> void:
	dashing = true
	dash_timer = DASH_COOLDOWN
	var dir = Vector2(0,0)

	_end_crouch()

	if (velocity.x == 0 && not is_on_floor()):
		dir = Vector2(0, -1)
	else:
		dir = Vector2(-1 if _anim.flip_h else 1, 0)
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

	anim_player.play("scale_normal")

	if dashing:
		_anim.play("Dash")
	elif sliding:
		_anim.play("Slide")
	elif crouching:
		_anim.play("Crouch")
	elif _is_touching_wall_full() and not is_on_floor():
		_anim.play("Wall")
	elif not is_on_floor():
		_anim.play("Jump")
	elif punching > 0.0:
		_anim.play("Punch")
	elif speed < 5.0:
		_anim.play("Idle")
	else:
		anim_player.play("scale_down")
		_anim.play("Run")
		if not footstep_sfx.playing and randf() < 0.2:
			footstep_sfx.play()

func yoyo_entered(body: Node) -> void:
	var enemy := body.get_parent()
	if not enemy is Enemy or not enemy.is_in_group("Enemy"):
		return
		
	var hit := (body as Node2D).global_position
	hit.y -= 16

	last_hit_position = hit
	yoyo_enemy = enemy
	yoyo_enemy_body = body as CharacterBody2D
	yoyo.visible = true

	_yoyo_timer = _yoyo_duration
	_yoyo_returning = false
	return

func _on_stun_body_entered(body: Node) -> void:
	var enemy := body.get_parent()
	if not enemy is Enemy or not enemy.is_in_group("Enemy"):
		return

	enemy.stun_timer = STUN_TIME

func _throw_yoyo() -> void:
	yoyo.show()
	yoyo.global_position = global_position + Vector2(-150 if _anim.flip_h else 150, -20)
	return

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
	if not enemy is Enemy or not enemy.is_in_group("Enemy"):
		return

	var dir: Vector2 = (enemy.global_position - global_position).normalized()
	enemy.take_hit(dir, punching, 100.0, 30)


func _on_dash_body_hit(body: Node) -> void:
	var enemy := body.get_parent()
	if not enemy is Enemy or not enemy.is_in_group("Enemy"):
		return

	var hit := (body as Node2D).global_position
	hit.y -= 16

	last_hit_position = hit
	yoyo_enemy = enemy
	yoyo_enemy_body = body as CharacterBody2D
	yoyo.visible = true

	_yoyo_timer = _yoyo_duration
	_yoyo_returning = false

	enemy.take_dash(Vector2.UP,dash_timer, 400.0, 40)

func zip_entered(body:Node2D)->void:
	zipline_dir = body.get_parent().get_parent().get_dir()
	if velocity.x < 0:
		zipline_dir = zipline_dir * -1
	_on_zipline = true
func zip_exited(_body:Node2D)->void:
	_on_zipline = false	

func crane_entered(body:Node2D)->void:
	crane_point = body.get_parent().get_parent().get_point()
	_in_crane_area = true
func crane_exited(_body:Node2D)->void:
	_in_crane_area = false
	
func calculate_crane_dir()->void:
	crane_dir = crane_point - global_position
	crane_dir.normalized()

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

func _heal_player()->void:
	var missing_health:float = MAX_HEALTH-health_value
	health_value +=(missing_health*0.35)+10.0
	health_value = clamp(health_value,1,MAX_HEALTH)

func _end_level(body :Node) -> void:
	if body is not Player:
		return
	levelEndScene.show()
	get_parent().endOfLevel()
