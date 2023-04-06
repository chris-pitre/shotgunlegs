extends Node

signal changed_area

func _change_area(scene: PackedScene, player_x: int, player_y: int) -> void:
	emit_signal("changed_area", scene, player_x, player_y)
