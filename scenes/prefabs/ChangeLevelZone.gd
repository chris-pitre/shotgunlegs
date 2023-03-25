extends Area2D

@onready var area = $CollisionShape2D

@export var next_level: PackedScene

func _on_body_entered(body):
	if body.is_in_group("Player"):
		SceneManagerSingleton._change_area(next_level)


