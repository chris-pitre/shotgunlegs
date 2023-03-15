extends CharacterBody2D

class_name Enemy

@export var HP: int = 50
@export var PUSH_FORCE: int = 750

@onready var hurtbox = $Hurtbox
@onready var hitbox = $Hitbox


var player_position: Vector2

func _physics_process(delta) -> void:
	player_position = to_local(get_tree().get_first_node_in_group("Player").global_position)
	velocity = velocity.move_toward(player_position, 10)
	move_and_slide()

func _on_hitbox_body_entered(body) -> void:
	if body is Player and "velocity" in body:
		body.velocity = velocity.normalized() * PUSH_FORCE
		velocity = -velocity.normalized() * (PUSH_FORCE / 4)

func _on_hurtbox_body_entered(body) -> void:
	if body is Bullet:
		HP -= 1
		for bullets in get_tree().get_nodes_in_group("Bullet"):
			if body == bullets:
				velocity += bullets.linear_velocity * 0.1
				bullets.emit_signal("target_hit")
		if HP <= 0:
			queue_free()  
