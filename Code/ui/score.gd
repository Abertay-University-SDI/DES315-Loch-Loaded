extends Label

@onready var background_score = $"Background Score"
@onready var added_score = $Added_Score
@onready var player: Player = get_parent().get("player")

var displayed_score: float = 0      # what is currently shown
var target_score: float = 0          # total score to reach

# Added score motion
var added_velocity: Vector2 = Vector2.ZERO
var flying: bool = false
var added_amount: int = 0

# Score lerp timing
var score_lerp_speed: float = 6.0   # higher = faster

# Tuning
var move_speed: float = 8.0
var slam_threshold: float = 5.0


func add_score(amount: int) -> void:
	added_amount += amount
	added_score.text = "+" + str(added_amount)

	# Start position (slightly above the main score)
	added_score.position = Vector2(0, 64)

	# Reset motion
	added_velocity = Vector2.ZERO
	flying = true


func update_score_display() -> void:
	# Display main score
	if displayed_score <= 0:
		text = ""
	else:
		text = str(int(displayed_score))

	background_score.visible_characters = background_score.text.length() - text.length()

	# Display added score if there’s value
	added_score.visible = added_amount > 0 && flying


func _ready() -> void:
	update_score_display()


func _process(delta: float) -> void:
	# Sync with player score
	if target_score < player.score:
		add_score(player.score - int(target_score))
		target_score = player.score

	# ===== MOVE ADDED SCORE =====
	if flying:
		var target_pos = Vector2.ZERO  # main label position
		var dir = (target_pos - added_score.position)

		# Accelerate toward target
		added_velocity += dir * move_speed * delta
		added_score.position += added_velocity * delta

		# Slam detection
		if dir.length() < slam_threshold:
			flying = false
			added_velocity = Vector2.ZERO

			# Pop effect
			scale = Vector2(1.2, 1.2)

	# ===== LERP MAIN SCORE AFTER SLAM =====
	# Only start lerping once the +X has finished flying
	if added_amount > 0 and flying == false:
		# Smoothly lerp displayed_score toward target_score
		displayed_score = lerp(displayed_score, target_score, delta * score_lerp_speed)

		# Snap if very close
		if abs(displayed_score - target_score) < 0.1:
			displayed_score = target_score
			# Only remove added_amount when main score finishes lerping
			added_amount = 0

	# Smoothly return scale to normal after pop
	scale = scale.lerp(Vector2.ONE, delta * 10.0)

	update_score_display()
