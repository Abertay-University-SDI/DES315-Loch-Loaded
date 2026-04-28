extends Node

var colorBlindMode = 0
var filmGrain = false
var screenShake = true
var gameModeEasy = false
var yoyoAbilityUnlocked = false
var upwardsDashAbilityUnlocked = false
#var powerGlovesAbilityUnlocked = false
const spray_cans_needed = 3

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

func getFilmGrainMode() -> bool:
	return filmGrain

func setFilmGrainMode(newMode: bool) -> void:
	filmGrain = newMode

func getScreenShakeMode() -> bool:
	return screenShake

func setScreenShakeMode(newMode: bool) -> void:
	screenShake = newMode

func getGameModeEasy() -> bool:
	return gameModeEasy

func setGameModeEasy(newMode: bool) -> void:
	gameModeEasy = newMode
