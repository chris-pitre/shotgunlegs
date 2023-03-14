extends Area2D

signal spikes_entered

func _on_body_entered(body):
	if body is Player:
		spikes_entered.emit()
