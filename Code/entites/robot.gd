# robot.gd
# Melee/zap enemy. Patrols until the player enters its attack area,
# then commits to a zap attack after a short contact window.

class_name Robot
extends Enemy

@export var attack_area: Area2D
@export var attack_range: float = 50.0
@export var walk_speed: float = 40.0

@onready var _zap_line: Line2D = $alive_body/ZapAttackLine

const ZAP_DURATION       := 0.1
const CONTACT_THRESHOLD  := 0.25
const ATTACK_DELAY       := 0.25

var _contact_timer:   float = 0.0
var _attack_committed: bool = false
var _attack_timer:    float = 0.0
var _in_contact:       bool = false
var _zap_timer:       float = 0.0
var _zap_force:       float = 400.0


# ─── Setup ────────────────────────────────────────────────────────────────────

func _on_ready() -> void:
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	attack_area.body_exited.connect(_on_attack_area_body_exited)


func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "attack":
		_attack_committed = false
		_animation_player.play("idle")
		_try_attack()
	elif anim_name == "take_hit":
		_animation_player.play("idle")


# ─── Attack area signals ──────────────────────────────────────────────────────

func _on_attack_area_body_entered(body: Node) -> void:
	if body == _player or body.get_parent() == _player:
		_in_contact = true


func _on_attack_area_body_exited(body: Node) -> void:
	if body == _player or body.get_parent() == _player:
		_in_contact = false
		if not _attack_committed:
			_contact_timer = 0.0


# ─── Zap attack ───────────────────────────────────────────────────────────────

func _spawn_zap() -> void:
	_zap_line.clear_points()
	var zap_start := _alive.global_position
	zap_start.y -= 8.0
	_zap_line.global_position = zap_start
	_zap_line.add_point(Vector2.ZERO)

	var zap_end := _player.global_position - _alive.global_position
	zap_end.y -= 16.0
	_zap_line.add_point(zap_end)

	_zap_line.visible = true
	_zap_timer = ZAP_DURATION


func _try_attack() -> void:
	if _player.global_position.distance_to(_alive.global_position) < attack_range:
		_spawn_zap()
		_player.velocity      += _zap_force * (_player.global_position - _alive.global_position).normalized()
		_player.health_value  -= 20


# ─── Process ──────────────────────────────────────────────────────────────────

func _on_process(delta: float) -> void:
	# Zap line visibility
	if _zap_timer > 0.0:
		_zap_timer -= delta
	if _zap_timer <= 0.0:
		_zap_line.visible = false

	# Contact → commit window
	if _in_contact and not _attack_committed:
		_contact_timer += delta
		if _contact_timer >= CONTACT_THRESHOLD:
			_attack_committed = true
			_attack_timer     = ATTACK_DELAY

	# Committed attack countdown
	if _attack_committed:
		_attack_timer -= delta
		if _attack_timer <= 0.0:
			_try_attack()
			_attack_timer     = ATTACK_DELAY
			_attack_committed = false
			_contact_timer    = 0.0
			_in_contact       = false
			_animation_player.play("idle")
		else:
			_animation_player.play("attack")


func _on_physics_process(delta: float) -> void:
	if not _alive.is_on_floor():
		_alive.velocity += Vector2.DOWN * 1200.0 * delta

	if immunity <= 0.0 and not _attack_committed:
		_alive.velocity = Vector2(_direction * walk_speed, _alive.velocity.y)

	if not _has_ground_ahead():
		_direction *= -1
	if _has_wall_ahead():
		_direction *= -1

	_alive_sprite.frame = int(_direction > 0)
	_alive.move_and_slide()
