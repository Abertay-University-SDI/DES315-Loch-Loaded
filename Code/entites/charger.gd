extends Enemy
class_name Charger

@export var attack_range: float = 50.0
@export var walk_speed: float = 40.0

const CONTACT_THRESHOLD  := 0.25
const ATTACK_DELAY       := 0.25

var _contact_timer:   float = 0.0
var _attack_committed: bool = false
var _attack_timer:    float = 0.0
var _in_contact:       bool = false

var jump_fatigue :float= 0.0
const  JUMP_COOLDOWN = 1.8
var jump_force = 0.0
var jump_inc = 0.3
const MAX_JUMP_FORCE = 0.9

@onready var alive_sprite = $alive_body/Sprite2D

# ─── Setup ────────────────────────────────────────────────────────────────────

func _on_ready() -> void:
	_direction = -1


func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "attack":
		_attack_committed = false
		_animation_player.play("RESET")
		_try_attack()
	elif anim_name == "take_hit":
		_animation_player.play("RESET")


# ─── Attack area signals ──────────────────────────────────────────────────────

func _on_attack_area_body_entered(body: Node) -> void:
	if body == _player or body.get_parent() == _player:
		_in_contact = true


func _on_attack_area_body_exited(body: Node) -> void:
	if body == _player or body.get_parent() == _player:
		_in_contact = false
		if not _attack_committed:
			_contact_timer = 0.0


func _try_attack() -> void:
	if _player.global_position.distance_to(_alive.global_position) < attack_range:
		_player.health_value  -= 35


# ─── Process ──────────────────────────────────────────────────────────────────

func _on_process(delta: float) -> void:

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
	
	jump_fatigue-=delta
	
	if _alive.is_on_floor() and jump_fatigue<0.0:
		jump_force+=jump_inc
		_alive.velocity += Vector2(_direction*jump_force/2,-jump_force)*100.0
		
	if jump_inc > MAX_JUMP_FORCE:
		jump_inc = 0.0
		jump_fatigue = JUMP_COOLDOWN
		alive_sprite.rotate(_direction*0.3)
		
		

	if not _has_ground_ahead():
		_direction *= -1
	if _has_wall_ahead():
		_direction *= -1
	
	alive_sprite.rotate(_direction*0.3)
	_alive.move_and_slide()
