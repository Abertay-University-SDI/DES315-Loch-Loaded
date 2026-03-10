extends Control

@export var world : Node2D

@export var enemiesLabel : Label
@export var billLabel : Label
@export var timeLabel : Label
@export var scoreLabel : Label

var rankArray

func _updateText() -> void:
	rankArray = world.getStats()
	enemiesLabel.text = "Enemies destroyed: " + str(rankArray[0]) + " / " + str(rankArray[1])
	billLabel.text = "Bllboards painted: " + str(rankArray[2]) + " / " + str(rankArray[3])
	timeLabel.text = "Time taken: " + str(rankArray[4])
	scoreLabel.text = "Score: " + rankArray[5] 


func _on_button_pressed() -> void:
	SceneTransition.transition_to_path("res://Scenes/UI/studio.tscn")
