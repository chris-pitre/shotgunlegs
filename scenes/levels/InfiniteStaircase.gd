extends Area2D


@export var teleport_back_to: Node


func _on_body_entered(body):
	body.global_position = teleport_back_to.global_position
