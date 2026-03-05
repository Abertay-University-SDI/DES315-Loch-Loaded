class_name Flybot
extends Node2D

@export var attack_area: Area2D
@export var attack_range:float = 50.0
@export var max_health: int = 3
@export var walk_speed: float = 40.0
@export var ground_check_distance: float = 8.0

var _player:Player = null

var _health: int

var _alive: CharacterBody2D
var _dead: RigidBody2D
var _alive_sprite: Sprite2D
var _dead_sprite: Sprite2D

var _animation_player: AnimationPlayer

var _direction: int = -1 # -1 = left, 1 = right

var immunity: float = 0.0
var _is_dead: bool = false

var _contact_timer: float = 0.0        # how long robot has been touching player
var _attack_committed: bool = false    # true once 0.25s contact threshold is met
var _attack_timer: float = 0.0         # countdown after committing to attack
const CONTACT_THRESHOLD: float = 0.25
const ATTACK_DELAY: float = 0.25
var _in_contact: bool = false

@onready var _zap_line: Line2D = $alive_body/ZapAttackLine
const ZAP_DURATION := 0.1
var _zap_timer := 0.0
var _zap_force :float= 400.0

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
	
	_player = get_tree().get_first_node_in_group("player")
	# connect attack area signals
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	attack_area.body_exited.connect(_on_attack_area_body_exited)
	

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "attack":
		_attack_committed = false
		_animation_player.play("idle")
		_try_attack()
	elif anim_name == "take_hit":
		_animation_player.play("idle")

func _on_attack_area_body_entered(body: Node) -> void:
	if body == _player or body.get_parent() == _player:
		_in_contact = true

func _on_attack_area_body_exited(body: Node) -> void:
	if body == _player or body.get_parent() == _player:
		_in_contact = false
		# only reset if we haven't committed yet
		if not _attack_committed:
			_contact_timer = 0.0

func _spawn_zap() -> void:
	_zap_line.clear_points()
	var zap_start:Vector2= _alive.global_position
	zap_start.y -=8
	_zap_line.global_position = zap_start
	_zap_line.add_point(Vector2.ZERO)
	
	var zap_end:Vector2= _player.global_position -_alive.global_position
	zap_end.y-=16
	_zap_line.add_point(zap_end)
	
	_zap_line.visible = true
	_zap_timer = ZAP_DURATION

func _try_attack() -> void:
	if (_player.global_position.distance_to(_alive.global_position) < attack_range):
		_spawn_zap()
		_player.velocity+= _zap_force* (_player.global_position-_alive.global_position).normalized()
		_player.health_value -= 35
	print("Robot attacks!")


func take_hit(hit_dir: Vector2, hit_duration: float, force: float) -> void:
	if immunity > 0.0 and not (hit_duration < 0.0):
		return

	immunity = hit_duration

	if hit_duration < 0.0:
		immunity = 1.0

	_health -= 1
	print("Robot took hit! Remaining health: %d" % _health)

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
	print("Robot took a dash! Remaining health: %d" % _health)
	_animation_player.play("take_hit")

	if _health <= 0:
		_die(Vector2.DOWN, force)


func _has_ground_ahead() -> bool:
	var origin := _alive.global_position
	origin.x += _direction * 12.0

	var target := origin + Vector2.DOWN * ground_check_distance

	var space := get_world_2d().direct_space_state

	var query := PhysicsRayQueryParameters2D.create(origin, target)
	query.collision_mask = 3

	var result := space.intersect_ray(query)
	return result.size() > 0


func _has_wall_ahead() -> bool:
	if _alive.is_on_wall():
		var wall_dir := _alive.get_wall_normal().x
		return wall_dir * _direction < 0
	return false
	


func _physics_process(delta: float) -> void:
	if not _alive.visible:
		return

	if immunity <= 0 && !_attack_committed:
		_alive.velocity = Vector2(_direction * walk_speed, _alive.velocity.y)

	if _has_wall_ahead():
		_direction *= -1

	_alive_sprite.frame = int(_direction > 0)
	_alive.move_and_slide()


func _process(delta: float) -> void:
	immunity -= delta

	if immunity < 0 and not _is_dead:
		_alive.collision_layer = 1

	if _is_dead:
		return
	
	if _zap_timer > 0.0:
		_zap_timer -= delta
	if _zap_timer <= 0.0:
		_zap_line.visible = false
		
	# contact and attack commit logic
	if _in_contact and not _attack_committed:
		_contact_timer += delta
		if _contact_timer >= CONTACT_THRESHOLD:
			_attack_committed = true
			_attack_timer = ATTACK_DELAY

	if _attack_committed:
		_attack_timer -= delta
		if _attack_timer <= 0.0:
			_try_attack()
			_attack_timer = ATTACK_DELAY
			_attack_committed = false
			_contact_timer = 0.0
			_in_contact = false
		else:
			_animation_player.play("attack")


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
