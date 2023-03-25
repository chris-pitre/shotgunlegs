extends Node

signal changed_area

func _change_area(scene: PackedScene) -> void:
	emit_signal("changed_area", scene)
