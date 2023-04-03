extends Area2D

var picked_up = false

func _on_body_entered(body):
	if body is Player and not picked_up:
		body.add_shells(1)
		picked_up = true
		visible = false
		await get_tree().create_timer(1).timeout
		picked_up = false
		visible = true
