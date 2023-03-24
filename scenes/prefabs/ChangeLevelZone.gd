extends Area2D

@onready var area = $CollisionShape2D
@onready var blackout = $Sprite2D

@export var next_level: Resource 

func _on_body_entered(body):
	if body.is_in_group("Player"):
		var tween = get_tree().create_tween()
		tween.set_trans(Tween.TRANS_EXPO)
		await tween.tween_property(blackout, "modulate", Color(0, 0, 0, 1), 0.25).finished
		get_tree().change_scene_to_file(next_level.resource_path)


