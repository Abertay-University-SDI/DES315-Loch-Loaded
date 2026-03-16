class_name Bullet
extends CharacterBody2D

@onready var hurt_box:Area2D=$HurtBox

@export var lifetime:float = 5.0
@export var damage: int = 5

@onready var sprite:Sprite2D = $Sprite2D

func _ready() -> void:
	hurt_box.body_entered.connect(body_hit)

func launch(dir: Vector2, speed: float) -> void:
	velocity = dir * speed
	##rotation = dir.angle() + PI / 2.0

func body_hit(_body:Node2D):
	if _body.get_parent() is Flybot:
		return
	
	if _body is Player:
		var player_body = _body as Player
		player_body.health_value -=damage
	queue_free()

func _process(delta: float) -> void:
	lifetime-=delta
	var mat = sprite.material as ShaderMaterial
	mat.set_shader_parameter("Velocity",velocity)
	mat.set_shader_parameter("World Pos",global_position)
	if lifetime < 0:
		queue_free()

func _physics_process(_delta: float) -> void:
	var _collision := move_and_slide()
	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		var body := col.get_collider()
		if body.has_method("take_hit"):
			body.take_hit(velocity.normalized(), 0.5, 150.0)
		queue_free()
