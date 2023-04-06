extends Area2D

@onready var area = $CollisionShape2D

@export var next_level: PackedScene
@export var player_x: int
@export var player_y: int

func _on_body_entered(body) -> void:
	if body.is_in_group("Player"):
		SceneManagerSingleton._change_area(next_level, player_x, player_y)


