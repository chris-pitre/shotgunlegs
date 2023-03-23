extends CharacterBody2D

class_name Player

const bulletPath = preload('res://scenes/actors/player/Bullet.tscn')
const SPEED_CAP = 80000

@export var JUMP_FORCE: int = PlayerSingleton.JUMP_FORCE
@export var MAX_SPEED: int = PlayerSingleton.MAX_SPEED
@export var ACCELERATION: int = PlayerSingleton.ACCELERATION
@export var FRICTION: int = PlayerSingleton.FRICTION
@export var GRAVITY: int = PlayerSingleton.GRAVITY
@export var MAX_AMMO: int = PlayerSingleton.MAX_AMMO
@export var UI: Control

@onready var animatedSprite = $AnimatedSprite2D
@onready var gunTimer = $GunTimer
@onready var slopeTimer = $SlopeTimer
@onready var shotgunFire = $SFX/ShotgunFire
@onready var shotgunReload = $SFX/ShotgunReload
@onready var camera = $PlayerCamera

var AMMO = 0
var cursorVector = Vector2.ZERO
var onSlope = false

func _ready() -> void:
	animatedSprite.play("idle")
	UI.set_max_shells(MAX_AMMO)

func _physics_process(_delta) -> void:
	#Handling slopes
	if rad_to_deg(get_floor_angle()) > 44:
		onSlope = true
		slopeTimer.start(0.1)
	elif slopeTimer.is_stopped():
		onSlope = false
	
	animatedSprite.flip_h = false if get_last_motion().x > 0 else true
	#Animations
	if onSlope:
		animatedSprite.play("roll")
		animatedSprite.speed_scale = clampf(velocity.length() / 100, 0, 8)
	else:
		animatedSprite.speed_scale = 1

	var input = Vector2.ZERO
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	cursorVector = get_global_mouse_position() - position
	
	move_camera()
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
	velocity.x = move_toward(velocity.x, MAX_SPEED * sign(amount), ACCELERATION)

## Shoots shotgun and applies force in opposite direction
func shoot() -> void:
	velocity += cursorVector.normalized() * JUMP_FORCE
	shotgunFire.play()
	for _i in range(10):	
		var bullet = bulletPath.instantiate()
		bullet.position = $Marker2D.position
		bullet.rotation = cursorVector.angle()
		var randomBulletSpeed = Vector2(2000 + randf_range(-400, 400), 0)
		var randomAngle = cursorVector.angle() + randf_range(-0.25, 0.25)
		bullet.apply_impulse(randomBulletSpeed.rotated(randomAngle), Vector2.ZERO)
		add_child(bullet)
	gunTimer.start(0.25)
	AMMO -= 1
	UI.set_shells(AMMO)

## Handles if player is able to shoot and reloads gun on the ground
func shoot_and_reload() -> void:
	if AMMO > 0:
		if gunTimer.is_stopped() and Input.is_action_just_pressed("mouse1"):
			shoot()
	if  AMMO < MAX_AMMO and is_on_floor() and gunTimer.is_stopped() and not onSlope:
		shotgunReload.play()
		AMMO = MAX_AMMO
		UI.reload_shells()

## Does movement based off input axis if player is on floor and not on a slope
## Otherwise, handles tumbling movement off a slope
func do_movement(input) -> void:
	if is_on_floor():
		if not onSlope:
			if input == 0:
				apply_friction()
				animatedSprite.play("idle")
			else:
				apply_acceleration(input)
				animatedSprite.play("walk")
		else:
			velocity.x = move_toward(velocity.x, get_floor_normal().x * SPEED_CAP, FRICTION)
			velocity.y = move_toward(velocity.y, 1 * SPEED_CAP, GRAVITY)
			
## Camera position
func move_camera() -> void:
	camera.global_position = global_position + (cursorVector / 6)


func set_max_shells(x: int) -> void:
	MAX_AMMO = x
	UI.set_max_shells(x)
