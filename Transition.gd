extends CanvasLayer

signal anim_finished

func _ready():
	change_scene()

func change_scene():
	$AnimationPlayer.play("fade_to_black")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fade_to_black":
		emit_signal("anim_finished")
		$AnimationPlayer.play("fade_in")
