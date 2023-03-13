extends Area2D

var won = false

func _on_body_entered(body):
	if not won:
		$AudioStreamPlayer.play()
		won = true
		$GPUParticles2D.emitting = true
