extends AnimatedSprite2D

@export var punch_force: Vector2 = Vector2(-128, 0)

var punching = false

func _on_area_2d_body_entered(_body):
	if "velocity" in _body:
		if not punching:
			punch()

func punch() -> void:
	punching = true
	play("punch")
	await get_tree().create_timer((1.0/12.0) * 7).timeout
	for body in $Area2D.get_overlapping_bodies():
		if "velocity" in body:
			body.velocity += punch_force + Vector2(0, -256)
	await animation_finished
	punching = false
	for body in $Area2D.get_overlapping_bodies():
		if "velocity" in body:
			punch()
