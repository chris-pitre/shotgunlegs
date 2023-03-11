extends CharacterBody2D

const bulletPath = preload('res://scenes/actors/player/Bullet.tscn')

@export var JUMP_FORCE: int = -140
@export var MAX_SPEED: int = 100
@export var ACCELERATION: int = 10
@export var FRICTION: int = 10
@export var GRAVITY: int = 4
@export var MAX_AMMO: int = 2
@export var tilemap: TileMap

@onready var animatedSprite = $AnimatedSprite2D
@onready var timer = $Timer
@onready var slopeRayCast = $SlopeRayCast

var AMMO = 0
var cursorVector = Vector2.ZERO
var notTouchedWall = false
var onSlope = false

func _ready() -> void:
	animatedSprite.play("idle")

func _physics_process(_delta) -> void:
	apply_gravity()
	var input = Vector2.ZERO
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	#Handling slopes
	var steepness = get_steepness()
	if steepness > 44.0:
		onSlope = true
	else:
		onSlope = false
	
	#Animations
	if onSlope:
		animatedSprite.play("roll")
		animatedSprite.speed_scale = clampf(velocity.length() / 100, 0, 8)
		animatedSprite.flip_h = false if get_last_motion().x > 0 else true
	else:
		animatedSprite.play("idle")
		animatedSprite.speed_scale = 1

	if is_on_floor():
		notTouchedWall = true
		if not onSlope:
			if input.x == 0:
				apply_friction()
			else:
				apply_acceleration(input.x)

	if is_on_wall_only() and notTouchedWall and steepness > 46:
		velocity = Vector2.ZERO
		await get_tree().create_timer(.1, false).timeout
		notTouchedWall = false

	cursorVector = get_global_mouse_position() - position

	if AMMO > 0 and timer.is_stopped():
		if Input.is_action_just_pressed("mouse1"):
			shoot()
	elif is_on_floor() and not onSlope:
		AMMO = MAX_AMMO

	if Input.is_action_pressed("ui_accept"):
		get_tree().reload_current_scene()
	
	move_and_slide()
	


func apply_gravity() -> void:
	velocity.y += GRAVITY

func apply_friction() -> void:
	velocity.x = move_toward(velocity.x, 0, FRICTION)

func apply_acceleration(amount) -> void:
	velocity.x = move_toward(get_velocity().x, MAX_SPEED * amount, ACCELERATION)

func shoot() -> void:
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

func get_steepness() -> float:
	return abs((-90) - rad_to_deg(slopeRayCast.get_collision_normal().angle()))
