extends CharacterBody2D

const bulletPath = preload('res://scenes/actors/player/Bullet.tscn')
const SPEED_CAP = 80000

@export var JUMP_FORCE: int = -140
@export var MAX_SPEED: int = 100
@export var ACCELERATION: int = 10
@export var FRICTION: int = 10
@export var GRAVITY: int = 4
@export var MAX_AMMO: int = 2
@export var UI: Control

@onready var animatedSprite = $AnimatedSprite2D
@onready var timer = $Timer
@onready var slopeRayCast = $SlopeRayCast

var AMMO = 0
var cursorVector = Vector2.ZERO
var onSlope = false
var steepness = 0

func _ready() -> void:
	animatedSprite.play("idle")

func _physics_process(_delta) -> void:
	#Handling slopes
	steepness = get_steepness()
	if abs(steepness) > 44.0:
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

	var input = Vector2.ZERO
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	apply_gravity()
	do_movement(input.x)
	shoot_and_reload()
	
	if Input.is_action_pressed("ui_accept"):
		get_tree().reload_current_scene()
	
	move_and_slide()
	

## Applies gravity to player velocity
func apply_gravity() -> void:
	velocity.y += GRAVITY

## Applies friction to player velocity
func apply_friction() -> void:
	velocity.x = move_toward(velocity.x, 0, FRICTION)

## Applies acceleration to player velocity
func apply_acceleration(amount) -> void:
	velocity.x = move_toward(velocity.x, MAX_SPEED * amount, ACCELERATION)

## Shoots shotgun and applys force in opposite direction
func shoot() -> void:
	cursorVector = get_global_mouse_position() - position
	velocity += cursorVector.normalized() * JUMP_FORCE
	for _i in range(10):	
		var bullet = bulletPath.instantiate()
		bullet.position = $Marker2D.global_position
		bullet.rotation = cursorVector.angle()
		var randomBulletSpeed = Vector2(2000 + randf_range(-400, 400), 0)
		var randomAngle = cursorVector.angle() + randf_range(-0.25, 0.25)
		bullet.apply_impulse(randomBulletSpeed.rotated(randomAngle), Vector2.ZERO)
		get_parent().add_child(bullet)
	timer.start(0.25)
	AMMO -= 1
	UI.set_shells(AMMO)

## Gets angle of slope from raycast
func get_steepness() -> float:
	return (-90) - rad_to_deg(slopeRayCast.get_collision_normal().angle())

## Handles if player is able to shoot and reloads gun on the ground
func shoot_and_reload() -> void:
	if AMMO > 0:
		if timer.is_stopped() and Input.is_action_just_pressed("mouse1"):
			shoot()
	if  AMMO < MAX_AMMO and is_on_floor() and timer.is_stopped() and not onSlope:
		AMMO = MAX_AMMO
		UI.reload_shells()

## Does movement based off input axis if player is on floor and not on a slope
## Otherwise, handles tumbling movement off a slope
func do_movement(input) -> void:
	if is_on_floor():
		if not onSlope:
			if input == 0:
				apply_friction()
			else:
				apply_acceleration(input)
		else:
			if steepness < 0:
				velocity.x = move_toward(velocity.x, 0.75 * SPEED_CAP, ACCELERATION)
			elif steepness > 0:
				velocity.x = move_toward(velocity.x, -0.75 * SPEED_CAP, ACCELERATION)
			velocity.y = move_toward(velocity.y, 1 * 800000, GRAVITY)
