extends Area2D

@onready var area = $CollisionShape2D

@export var next_level: Resource 

func _on_body_entered(body):
	if body.is_in_group("Player"):
		get_tree().change_scene_to_file(next_level.resource_path)

