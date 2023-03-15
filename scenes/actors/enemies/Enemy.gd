extends CharacterBody2D

class_name Enemy

@export var HP: int = 5

@onready var hurtbox = $Hurtbox

func _on_hitbox_body_entered(body) -> void:
	pass

func _on_hurtbox_body_entered(body) -> void:
	if body is Bullet:
		HP -= 1
		for bullets in get_tree().get_nodes_in_group("Bullet"):
			if body == bullets:
				bullets.emit_signal("target_hit")
		if HP <= 0:
			queue_free()  
