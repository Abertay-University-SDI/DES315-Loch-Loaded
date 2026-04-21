# flybot.gd
# Flying enemy. Patrols with a sine hover until the player is in range,
# then locks on and fires bullets at a set cooldown.

class_name Flybot
extends Enemy

@export var attack_area: Area2D
@export var search_radius:  float = 150.0
@export var attack_range:   float = 145.0
@export var patrol_speed:   float = 40.0
@export var hover_speed:    float = 15.0
@export var shoot_cooldown: float = 0.5
@export var bullet_speed:   float = 200.0

@export var shootSound: AudioStreamPlayer2D

var bullet: PackedScene = load("res://Scenes/Entites/bullet.tscn")

enum State { PATROL, LOCKON }
var _state: State = State.PATROL

var _shoot_timer: float = 0.0
var _hover_time:  float = 0.0
var _move_time: float = 0.0


# ─── Setup ────────────────────────────────────────────────────────────────────

func _on_ready() -> void:
	max_health = 70
	_score_reward = 25
	_health = max_health
	pass  # no extra signals needed for Flybot


func _on_animation_finished(anim_name: String) -> void:
	if anim_name in ["attack", "take_hit"]:
		_animation_player.play("idle")


# ─── State machine ────────────────────────────────────────────────────────────

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
				_shoot_timer = 0.5          # brief pause before first shot
		State.LOCKON:
			if dist > search_radius * 1.2:  # hysteresis to prevent flickering
				_state = State.PATROL
				_animation_player.play("idle")


# ─── Patrol ───────────────────────────────────────────────────────────────────

func _do_patrol(delta: float) -> void:
	if _has_wall_ahead() || _move_time >= 5:
		_move_time = 0.0
		_direction *= -1

	_hover_time += delta
	_move_time += delta
	var hover_y := sin(_hover_time * 2.0) * hover_speed

	_alive.velocity     = Vector2(_direction * patrol_speed, hover_y)
	_alive_sprite.frame = int(_direction > 0)


# ─── Lock-on & shooting ───────────────────────────────────────────────────────

func _face_player() -> void:
	if _player == null:
		return
	var diff    := _player.global_position.x - _alive.global_position.x
	_direction   = 1 if diff > 0 else -1
	_alive_sprite.frame = int(_direction > 0)


func _do_lockon(delta: float) -> void:
	_face_player()

	_hover_time += delta
	_alive.velocity = Vector2(0.0, sin(_hover_time * 3.0) * hover_speed)

	_shoot_timer -= delta
	if _shoot_timer <= 0.0:
		_shoot_timer = shoot_cooldown
		if _get_player_distance() <= attack_range:
			_fire_bullet()
		else:
			# Spotted but out of range — creep toward player
			_alive.velocity.x = _direction * patrol_speed


func _fire_bullet() -> void:
	if bullet == null or _player == null:
		return

	shootSound.play()
	var b = bullet.instantiate()
	get_tree().current_scene.add_child(b)
	b.global_position = _alive.global_position


	var player_torso = _player.global_position + Vector2(0.0,-16.0)
	var dir := (player_torso - _alive.global_position).normalized()
	if b.has_method("launch"):
		b.launch(dir, bullet_speed)
	else:
		b.velocity = dir * bullet_speed


# ─── Process ──────────────────────────────────────────────────────────────────

func _on_process(_delta: float) -> void:
	_update_state()


func _on_physics_process(delta: float) -> void:
	if immunity <= 0.0 and stun_timer<0:
		match _state:
			State.PATROL:
				_do_patrol(delta)
			State.LOCKON:
				_do_lockon(delta)
				
	if _alive.velocity.y < 0:
		_alive.velocity.y /=1.1
	
	if stun_timer> 0.0:
		_alive.velocity.y += 200.0*delta

	_alive.move_and_slide()
