extends Enemy
class_name ChargerBoss

@onready var _slam_particle: GPUParticles2D = $alive_body/GPUParticles2D
@onready var _hurt_box: Area2D              = $alive_body/Hurt_box
@export var idle_sfx: AudioStreamPlayer2D
@export var bounce_sfx: AudioStreamPlayer2D
@export var damagePlayer_sfx: AudioStreamPlayer2D

const JUMP_COOLDOWN := 0.6
const MAX_CHARGE    := 4.0
const CHARGE_RATE   := 2.0
const BASE_LAUNCH   := 100.0
const MAX_BOUNCES   := 5
const HIT_COOLDOWN  := 0.5

var _charge:        float = 0.0
var _jump_cooldown: float = 0.0
var _airborne:       bool = false
var _was_on_floor:   bool = false
var _bounces:         int = 0
var _hit_cooldown:  float = 0.0


func _on_ready() -> void:
	max_health = 140
	_health = max_health
	_score_reward = 500
	_direction = -1
	_hurt_box.body_entered.connect(_hurt_player)
	idle_sfx.play()


func _on_animation_finished(anim_name: String) -> void:
	if anim_name in ["attack", "take_hit"]:
		_animation_player.play("RESET")


func _hurt_player(body: Node) -> void:
	if body is not Player or _hit_cooldown > 0.0:
		return
	_hit_cooldown = HIT_COOLDOWN
	damagePlayer_sfx.play()
	(body as Player).health_value -= 20 if _airborne else 10


func _on_process(delta: float) -> void:
	_hit_cooldown  -= delta
	_jump_cooldown -= delta


func _on_physics_process(delta: float) -> void:
	if _alive.is_on_wall():
		bounce_sfx.play()
		_direction *= -1
	var on_floor :bool= _alive.is_on_floor()

	if not on_floor:
		_alive.velocity += Vector2.DOWN * 1200.0 * delta
		
	if stun_timer < 0:

		if on_floor and not _was_on_floor:
			_on_land()
		_was_on_floor = on_floor

		if on_floor and not _airborne:
			if _jump_cooldown <= 0.0:
				_charge += CHARGE_RATE * delta
				_charge  = minf(_charge, MAX_CHARGE)
				_alive_sprite.rotate(_direction * 0.25 * _charge)
				if _charge >= MAX_CHARGE:
					_launch()


		if _airborne:
			_alive_sprite.rotate(_direction * 0.25)

	_alive.move_and_slide()


func _launch() -> void:
	_alive.velocity = Vector2(_direction * _charge, -_charge) * BASE_LAUNCH
	_airborne = true
	_charge   = 0.0
	_slam_particle.emitting = false


func _on_land() -> void:
	if not _airborne:
		return
	_slam_particle.emitting = true
	_bounces += 1
	if _bounces >= MAX_BOUNCES:
		_direction*=-1
		_airborne      = false
		_bounces       = 0
		_jump_cooldown = JUMP_COOLDOWN
		_animation_player.play("RESET")
	else:
		_alive.velocity = Vector2(_direction * MAX_CHARGE, -MAX_CHARGE) * BASE_LAUNCH
