extends Label

@onready var background_score = $"Background Score"
@onready var added_score = $Added_Score
@onready var player: Player = get_parent().get("player")

var displayed_score: float = 0
var target_score: float = 0

var added_value: float = 0  # this will lerp down

var lerp_speed: float = 1.0
var added_lerp_speed: float = 1.0

func add_score(amount: int) -> void:
	target_score += amount
	added_value += amount  # accumulate if multiple hits


func update_score_display() -> void:
	text = str(int(displayed_score))
	if displayed_score == 0:
		text = ""
	
	background_score.visible_characters = background_score.text.length() - text.length()

	# Update added score label
	if added_value > 0.1:
		added_score.text = "+" + str(int(added_value))
		added_score.visible = true
	else:
		added_score.visible = false


func _ready() -> void:
	update_score_display()


func _process(delta: float) -> void:
	# Sync with player score
	if target_score < player.score:
		add_score(player.score - target_score)

	# Lerp main score
	displayed_score = lerp(displayed_score, target_score, delta * lerp_speed)

	# Lerp added score DOWN to 0
	added_value = lerp(added_value, 0.0, delta * added_lerp_speed)

	# Snap to avoid jitter
	if abs(displayed_score - target_score) < 0.1:
		displayed_score = target_score

	if abs(added_value) < 0.1:
		added_value = 0

	added_score.visible = added_value > 0

	update_score_display()
