extends Node

var colorBlindMode = 0
var yoyoAbilityUnlocked = false
var upwardsDashAbilityUnlocked = false
#var powerGlovesAbilityUnlocked = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	

func getColorBlindMode() -> int:
	return colorBlindMode	

func setColorBlindMode(newMode: int) -> void:
	colorBlindMode = newMode
