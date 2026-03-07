class_name Flybot
extends Node2D

@export var attack_area: Area2D
@export var search_radius: float = 150.0      # how far it can "see" the player
@export var attack_range: float = 145.0       # max distance to shoot from
@export var max_health: int = 2
@export var patrol_speed: float = 40.0        # left/right patrol speed
@export var hover_speed: float = 15.0         # gentle vertical bob while patrolling
@export var ground_check_distance: float = 8.0

@export var shoot_cooldown: float = 0.5       # seconds between shots
@export var bullet_speed: float = 200.0

var bullet: PackedScene = load("res://Scenes/Entites/bullet.tscn")

var _player: Player = null
var _health: int
var _alive: CharacterBody2D
var _dead: RigidBody2D
var _alive_sprite: Sprite2D
var _dead_sprite: Sprite2D
var _animation_player: AnimationPlayer

var _direction: int = -1                      # patrol direction: -1 left, 1 right
var _is_dead: bool = false
var immunity: float = 0.0

# State machine
enum State { PATROL, LOCKON }
var _state: State = State.PATROL

var _shoot_timer: float = 0.0                 # counts down to next shot
var _hover_time: float = 0.0                  # drives the sine bob

@onready var _zap_line: Line2D = $alive_body/ZapAttackLine
const ZAP_DURATION := 0.1
var _zap_timer := 0.0


func _ready() -> void:
	_health = max_health
	_player = get_tree().get_first_node_in_group("player")

	_alive = $alive_body
	_dead = $dead_body
	_animation_player = $AnimationPlayer
	_alive_sprite = _alive.get_node("Sprite2D")
	_dead_sprite = _dead.get_node("Sprite2D")

	_dead.freeze = true
	_dead.visible = false

	_animation_player.animation_finished.connect(_on_animation_finished)


func _on_animation_finished(anim_name: String) -> void:
	if anim_name in ["attack", "take_hit"]:
		_animation_player.play("idle")


# ─── State Logic ─────────────────────────────────────────────────────────────

func _get_player_distance() -> float:
	if _player == null:
		return INF
	return _alive.global_position.distance_to(_player.global_position)


func _update_state() -> void:
	var dist := _get_player_distance()
	match _state:
		State.PATROL:
			if dist <= search_radius:
				_state = State.LOCKON
				_shoot_timer = 0.5           # brief pause before first shot
		State.LOCKON:
			if dist > search_radius * 1.2:   # small hysteresis so it doesn't flicker
				_state = State.PATROL
				_animation_player.play("idle")


# ─── Patrol ──────────────────────────────────────────────────────────────────

func _has_wall_ahead() -> bool:
	if _alive.is_on_wall():
		return _alive.get_wall_normal().x * _direction < 0
	return false


func _has_ground_ahead() -> bool:
	var origin := _alive.global_position
	origin.x += _direction * 12.0
	var target := origin + Vector2.DOWN * ground_check_distance
	var query := PhysicsRayQueryParameters2D.create(origin, target)
	query.collision_mask = 3
	var result := get_world_2d().direct_space_state.intersect_ray(query)
	return result.size() > 0


func _do_patrol(delta: float) -> void:
	if _has_wall_ahead():
		_direction *= -1

	_hover_time += delta
	var hover_y := sin(_hover_time * 2.0) * hover_speed

	_alive.velocity = Vector2(_direction * patrol_speed, hover_y)
	_alive_sprite.frame = int(_direction > 0)


# ─── Lock-on & Shooting ──────────────────────────────────────────────────────

func _face_player() -> void:
	if _player == null:
		return
	var diff := _player.global_position.x - _alive.global_position.x
	_direction = 1 if diff > 0 else -1
	_alive_sprite.frame = int(_direction > 0)


func _do_lockon(delta: float) -> void:
	_face_player()

	# Hover in place with a gentle bob, no horizontal patrol
	_hover_time += delta
	_alive.velocity = Vector2(0.0, sin(_hover_time * 3.0) * hover_speed)

	_shoot_timer -= delta
	if _shoot_timer <= 0.0:
		_shoot_timer = shoot_cooldown
		if _get_player_distance() <= attack_range:
			_fire_bullet()
			_animation_player.play("attack")
		else:
			# Player spotted but out of range — creep toward them
			_alive.velocity.x = _direction * patrol_speed


func _fire_bullet() -> void:
	if bullet == null or _player == null:
		return

	var b = bullet.instantiate()
	get_tree().current_scene.add_child(b)
	b.global_position = _alive.global_position

	var dir := (_player.global_position - _alive.global_position).normalized()
	# Assumes your bullet has a speed property and a direction or velocity
	if b.has_method("launch"):
		b.launch(dir, bullet_speed)
	else:
		b.velocity = dir * bullet_speed


# ─── Zap Visual (kept for take_hit flash if you want it) ─────────────────────

func _spawn_zap() -> void:
	_zap_line.clear_points()
	var zap_start := _alive.global_position
	zap_start.y -= 8
	_zap_line.global_position = zap_start
	_zap_line.add_point(Vector2.ZERO)
	var zap_end := _player.global_position - _alive.global_position
	zap_end.y -= 16
	_zap_line.add_point(zap_end)
	_zap_line.visible = true
	_zap_timer = ZAP_DURATION


# ─── Damage ───────────────────────────────────────────────────────────────────

func take_hit(hit_dir: Vector2, hit_duration: float, force: float) -> void:
	if immunity > 0.0 and not (hit_duration < 0.0):
		return
	immunity = hit_duration if hit_duration >= 0.0 else 1.0
	_health -= 1
	_alive.velocity = hit_dir * force
	_animation_player.play("take_hit")
	if _health <= 0:
		_die(hit_dir, force)


func take_dash(hit_duration: float, force: float) -> void:
	if immunity > 0.0:
		return
	immunity = hit_duration
	_alive.collision_layer = 0
	_alive.velocity = Vector2(0.0, -force)
	_health -= 1
	_animation_player.play("take_hit")
	if _health <= 0:
		_die(Vector2.DOWN, force)


# ─── Process ─────────────────────────────────────────────────────────────────

func _physics_process(delta: float) -> void:
	if not _alive.visible:
		return

	if immunity <= 0.0:
		match _state:
			State.PATROL:
				_do_patrol(delta)
			State.LOCKON:
				_do_lockon(delta)

	_alive.move_and_slide()


func _process(delta: float) -> void:
	immunity -= delta
	if immunity < 0.0 and not _is_dead:
		_alive.collision_layer = 1

	if _is_dead:
		return

	if _zap_timer > 0.0:
		_zap_timer -= delta
		if _zap_timer <= 0.0:
			_zap_line.visible = false

	_update_state()


# ─── Death ────────────────────────────────────────────────────────────────────

func _apply_death_impulse(hit_dir: Vector2, force: float) -> void:
	_dead.apply_impulse(hit_dir * force)
	_dead.apply_torque_impulse(force * 10.4)


func _die(hit_dir: Vector2, force: float) -> void:
	_dead.global_position = _alive.global_position
	_dead.rotation = _alive.rotation
	_alive.set_physics_process(false)
	_alive.visible = false
	_alive.collision_layer = 0
	_alive.collision_mask = 0
	_is_dead = true
	_dead_sprite.frame = int(_direction > 0) + 2
	_dead.visible = true
	_dead.collision_layer = 0
	_dead.collision_mask = 1
	_dead.set_deferred("freeze", false)
	call_deferred("_apply_death_impulse", hit_dir, force)


func _get_dead() -> bool:
	return _is_dead
