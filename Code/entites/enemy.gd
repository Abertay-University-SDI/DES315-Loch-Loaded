# enemy.gd
# Base class for all enemies. Contains shared state, damage handling,
# death logic, and movement helpers. Children hook in via _on_ready(),
# _on_process(), _on_physics_process(), and _on_animation_finished().

class_name Enemy
extends Node2D

@export var max_health: int = 3
@export var ground_check_distance: float = 8.0

var _player: Player = null
var _health: int

var _alive: CharacterBody2D
var _dead: RigidBody2D
var _alive_sprite: Sprite2D
var _dead_sprite: Sprite2D
var _animation_player: AnimationPlayer
var _stun_effect:ColorRect

var _direction: int = -1        # -1 = left, 1 = right
var immunity: float = 0.0
var _is_dead: bool = false

var stun_timer :float= 0.0


# ─── Lifecycle ────────────────────────────────────────────────────────────────

func _ready() -> void:
	_health = max_health
	_player = get_tree().get_first_node_in_group("player")

	_alive = $alive_body
	_dead  = $dead_body
	_animation_player = $AnimationPlayer
	_stun_effect = $alive_body/Stun_Effect
	_alive_sprite = _alive.get_node("Sprite2D")
	_dead_sprite  = _dead.get_node("Sprite2D")

	_dead.freeze   = true
	_dead.visible  = false

	_animation_player.animation_finished.connect(_on_animation_finished)

	_on_ready()   # child-specific setup


func _on_ready() -> void:
	pass  # override in child


func _on_animation_finished(_anim_name: String) -> void:
	pass  # override in child


# ─── Process hooks ────────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	stun_timer -= delta
	immunity -= delta
	if immunity < 0.0 and not _is_dead:
		_alive.collision_layer = 1

	if _is_dead:
		return

	if stun_timer > 0:
		_stun_effect.show()
	else:
		_stun_effect.hide()

	_on_process(delta)


func _on_process(_delta: float) -> void:
	pass  # override in child


func _physics_process(delta: float) -> void:
	if not _alive.visible:
		return
	_on_physics_process(delta)


func _on_physics_process(_delta: float) -> void:
	pass  # override in child


# ─── Damage ───────────────────────────────────────────────────────────────────

func take_hit(hit_dir: Vector2, hit_duration: float, force: float, damage: int) -> void:
	if immunity > 0.0 and not (hit_duration < 0.0):
		return

	immunity = hit_duration if hit_duration >= 0.0 else 1.0
	_health -= damage
	_alive.velocity = hit_dir * force
	_animation_player.play("take_hit")

	if _health <= 0:
		_die(hit_dir, force)


func take_dash(hit_dir: Vector2, hit_duration: float, force: float, damage: int) -> void:
	if immunity > 0.0:
		return

	immunity = hit_duration
	_alive.collision_layer = 0
	_alive.velocity = Vector2(0.0, -force)
	_health -= damage
	_animation_player.play("take_hit")

	if _health <= 0:
		_die(hit_dir, force)


# ─── Movement helpers ─────────────────────────────────────────────────────────

func _has_ground_ahead() -> bool:
	var origin := _alive.global_position
	origin.x += _direction * 24.0
	var target := origin + Vector2.DOWN * ground_check_distance
	var query  := PhysicsRayQueryParameters2D.create(origin, target)
	query.collision_mask = 3
	return get_world_2d().direct_space_state.intersect_ray(query).size() > 0


func _has_wall_ahead() -> bool:
	if _alive.is_on_wall():
		return _alive.get_wall_normal().x * _direction < 0
	return false


# ─── Death ────────────────────────────────────────────────────────────────────

func _die(hit_dir: Vector2, force: float) -> void:
	
	_player._heal_player()
	
	_dead.global_position = _alive.global_position
	_dead.rotation        = _alive.rotation

	_alive.set_physics_process(false)
	_alive.visible          = false
	_alive.collision_layer  = 0
	_alive.collision_mask   = 0

	_is_dead = true
	_dead_sprite.frame     = int(_direction > 0) + 2
	_dead.visible          = true
	_dead.collision_layer  = 0
	_dead.collision_mask   = 1
	_dead.set_deferred("freeze", false)
	call_deferred("_apply_death_impulse", hit_dir, force)


func _apply_death_impulse(hit_dir: Vector2, force: float) -> void:
	_dead.apply_impulse(hit_dir * force)
	_dead.apply_torque_impulse(force * 10.4)


func _get_dead() -> bool:
	return _is_dead
