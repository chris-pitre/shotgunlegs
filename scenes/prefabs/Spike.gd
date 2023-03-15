extends Node2D

signal spikes_entered

func _on_hitbox_body_entered(body):
	if body is Player and "velocity" in body:
		body.velocity = body.velocity.bounce(body.velocity.normalized()) * 0.5
