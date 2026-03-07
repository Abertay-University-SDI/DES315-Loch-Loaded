class_name Bullet
extends CharacterBody2D

var damage: int = 10

func launch(dir: Vector2, speed: float) -> void:
	velocity = dir * speed
	rotation = dir.angle() + PI / 2.0

func _physics_process(_delta: float) -> void:
	var _collision := move_and_slide()
	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		var body := col.get_collider()
		if body.has_method("take_hit"):
			body.take_hit(velocity.normalized(), 0.5, 150.0)
		queue_free()
