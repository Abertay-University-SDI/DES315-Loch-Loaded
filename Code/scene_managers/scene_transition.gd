extends CanvasLayer

@onready var anim = $AnimationPlayer
@onready var background = $animated_background


func transition_to(scene:PackedScene):
	anim.play('transition')
	await anim.animation_finished
	get_tree().change_scene_to_packed(scene)
	anim.play_backwards('transition')

func transition_to_path(scene:String):
	anim.play('transition')
	await anim.animation_finished
	get_tree().change_scene_to_file(scene)
	anim.play_backwards('transition')
	
func death_reset():
	anim.play('death_trans')
	await anim.animation_finished
	get_tree().reload_current_scene()
	anim.play_backwards("death_trans")
