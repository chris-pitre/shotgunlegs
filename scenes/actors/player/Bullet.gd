extends RigidBody2D

@onready var tracer = $Tracer

func _ready():
	await get_tree().create_timer(.5, false).timeout
	queue_free()

func _process(_delta):
	tracer.global_position = get_parent().global_position
	
	var point = to_local(get_parent().global_position)
	
	tracer.add_point(-point)
	while tracer.get_point_count() > 20:
		tracer.remove_point(0)

func _on_KinematicBody2D_body_entered(body):
	if not body.is_in_group("Player"):
		queue_free()
