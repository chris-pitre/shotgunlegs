class_name Wind
extends Area2D

@export var wind: Vector2 = Vector2()

@onready var collision_shape = $CollisionShape2D
@onready var particles = $ParticleClip/GPUParticles2D
@onready var particles_clip = $ParticleClip

func _ready() -> void: #Match effects to collision area
	particles.process_material = particles.process_material.duplicate()
	particles_clip.texture = particles_clip.texture.duplicate()
	particles.process_material.direction.x = wind.x
	particles.process_material.direction.y = wind.y
	particles.process_material.initial_velocity_min = wind.length() * 64
	particles.process_material.initial_velocity_max = wind.length() * 64
	particles.process_material.emission_box_extents.x = collision_shape.shape.size.x / 2
	particles.process_material.emission_box_extents.y = collision_shape.shape.size.y / 2
	particles.amount = sqrt(collision_shape.shape.size.x * collision_shape.shape.size.y) / 4
	particles.visibility_rect = collision_shape.shape.get_rect()
	particles_clip.global_position = collision_shape.global_position
	particles_clip.texture.width = collision_shape.shape.size.x
	particles_clip.texture.height = collision_shape.shape.size.y

func _physics_process(_delta) -> void:
	if not Engine.is_editor_hint():
		for body in get_overlapping_bodies():
			if "velocity" in body:
				body.velocity += wind
