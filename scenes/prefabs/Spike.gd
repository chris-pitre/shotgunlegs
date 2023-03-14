extends Node2D

signal spikes_entered

func _on_hitbox_body_entered(body):
	if body is Player:
		spikes_entered.emit()
