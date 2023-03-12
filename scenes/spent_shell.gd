extends Sprite2D


var velocity: Vector2 = Vector2()
var rot_speed: float = 8.0

func _ready():
	velocity = Vector2(randf_range(-64, 64), -128)
	rot_speed = deg_to_rad(randf_range(-360, 360))
	await get_tree().create_timer(32).timeout
	queue_free()

func _process(delta):
	velocity += Vector2(0, 512) * delta
	rotation += rot_speed * delta
	global_position += velocity * delta
