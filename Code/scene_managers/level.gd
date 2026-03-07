extends Node2D

@onready var pause_menu = $CanvasLayer/PauseScene
@onready var resume_button = $CanvasLayer/PauseScene/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/BackGameButton
@export var enemies : Node2D
@export var billBoards : Node2D

var startTime
var totalEnemies :float = 0
var deadEnemies :float = 0
var totalBoards :float = 0
var paintedBoards :float = 0
var goodTime
var levelPercent :float = 0
var rank

func _ready() -> void:
	startTime = Time.get_ticks_msec()
	MenuMusic.stop()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		resume_button.grab_focus()
		pause_menu.show()
		get_tree().paused = true

func _process(_delta: float) -> void:
	return	

func endOfLevel():
	for enemy in enemies.get_children():
		totalEnemies = 5
		if (enemy._get_dead()):
			deadEnemies += 1

	for board in billBoards.get_children():
		totalBoards = 4
		if (board._get_painted()):
			paintedBoards += 1
	
	levelPercent = ((deadEnemies / totalEnemies) + (paintedBoards / totalBoards)) * 50
	if (levelPercent == 100):
		rank = "A"
		if (Time.get_ticks_msec() - startTime <= goodTime):
			rank = "S"
	elif (levelPercent >= 60):
		rank = "B"
		if (Time.get_ticks_msec() - startTime <= goodTime):
			rank = "A"
	else:
		rank = "C"
		if (Time.get_ticks_msec() - startTime <= goodTime):
			rank = "B"
	return
