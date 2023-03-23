extends Node2D


func _ready():
	$GPUParticles2D.emitting = true
	$GPUParticles2D2.emitting = true
	$AudioStreamPlayer2D.pitch_scale = randf_range(0.8, 1.2)
	await get_tree().create_timer(4).timeout
	queue_free()
