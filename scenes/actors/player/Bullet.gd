extends RigidBody2D

func _on_KinematicBody2D_body_entered(body):
	if not body.is_in_group("Player"):
		queue_free()
