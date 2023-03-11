extends CharacterBody2D

const bulletPath = preload('res://scenes/actors/player/Bullet.tscn')

@export var JUMP_FORCE: int = -140
@export var MAX_SPEED: int = 100
@export var ACCELERATION: int = 10
@export var FRICTION: int = 10
@export var GRAVITY: int = 4
@export var MAX_AMMO: int = 2

@onready var animatedSprite = $AnimatedSprite2D
@onready var timer = $Timer

var AMMO = 0
var cursorVector = Vector2.ZERO
var notTouchedWall = false

func _physics_process(_delta):
	apply_gravity()	
	var input = Vector2.ZERO
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	if is_on_floor():
		notTouchedWall = true
		if input.x == 0:
			apply_friction()
		else:
			apply_acceleration(input.x)

	if is_on_wall_only() and notTouchedWall:
		velocity = Vector2.ZERO
		await get_tree().create_timer(.1, false).timeout
		notTouchedWall = false

	cursorVector = get_global_mouse_position() - position

	if AMMO > 0 and timer.is_stopped():
		if Input.is_action_just_pressed("mouse1"):
			shoot()
	elif is_on_floor():
		AMMO = MAX_AMMO

	if Input.is_action_pressed("ui_accept"):
		get_tree().reload_current_scene()
	
	move_and_slide()
	


func apply_gravity():
	velocity.y += GRAVITY

func apply_friction():
	velocity.x = move_toward(velocity.x, 0, FRICTION)

func apply_acceleration(amount):
	velocity.x = move_toward(get_velocity().x, MAX_SPEED * amount, ACCELERATION)

func shoot():
	velocity += cursorVector.normalized() * JUMP_FORCE
	for _i in range(10):	
		var bullet = bulletPath.instantiate()
		bullet.position = $Marker2D.global_position
		bullet.rotation = cursorVector.angle()
		var randomBulletSpeed = Vector2(2000 + randf_range(-200, 200), 0)
		var randomAngle = cursorVector.angle() + randf_range(-0.25, 0.25)
		bullet.apply_impulse(randomBulletSpeed.rotated(randomAngle), Vector2.ZERO)
		get_parent().add_child(bullet)
	timer.start(0.25)
	AMMO -= 1
