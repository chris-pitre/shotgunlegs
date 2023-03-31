extends CharacterBody2D

class_name Enemy

@export var MAX_HP: int = 50
@export var PUSH_FORCE: int = 750

@onready var hurtbox = $Hurtbox/CollisionShape2D
@onready var hitbox = $Hitbox/CollisionShape2D
@onready var sprite = $AnimatedSprite2D
@onready var collision = $CollisionShape2D
@onready var original_position: Vector2 = global_position

var is_dead: bool = false
var player_position: Vector2
var HP: int = MAX_HP

func _physics_process(delta) -> void:
	print(position)
	if not is_dead:
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
			death()
			await get_tree().create_timer(5, false).timeout
			life()

func death() -> void:
	is_dead = true
	global_position = original_position
	velocity = Vector2.ZERO
	sprite.visible = false
	hurtbox.set_deferred("disabled", true)
	hitbox.set_deferred("disabled", true)
	collision.set_deferred("disabled", true)
	
func life() -> void:
	HP = MAX_HP
	is_dead = false
	sprite.visible = true
	hurtbox.set_deferred("disabled", false)
	hitbox.set_deferred("disabled", false)
	collision.set_deferred("disabled", false)
