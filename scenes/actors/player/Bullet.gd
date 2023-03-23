extends RigidBody2D

class_name Bullet

signal target_hit

@export var impact: PackedScene

@onready var tracer = $Tracer

func _ready():
	add_to_group("Bullet")
	await get_tree().create_timer(.5, false).timeout
	queue_free()

func _process(_delta):
	tracer.global_position = get_parent().global_position
	
	var point = to_local(get_parent().global_position)
	
	tracer.add_point(-point)
	while tracer.get_point_count() > 20:
		tracer.remove_point(0)

func _integrate_forces(state):
	if state.get_contact_count() > 0: # Impact particles
		var collision_pos = state.get_contact_local_position(0)
		var collision_norm = state.get_contact_local_normal(0)
		var new_impact = impact.instantiate()
		Game.world.projectiles.add_child(new_impact)
		new_impact.global_position = global_position
		# Makes it so projectiles point towards where the bullet is going, reflected across ground normal
		new_impact.rotation = (linear_velocity - (2 * (linear_velocity * \
			collision_norm)) * collision_norm).angle() + deg_to_rad(90)

func _on_KinematicBody2D_body_entered(body):
	if not body.is_in_group("Player"):
		queue_free()

func _on_target_hit():
	queue_free()
