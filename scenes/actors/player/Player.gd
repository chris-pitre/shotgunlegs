class_name Player
extends CharacterBody2D

enum STATES {
	IDLE,
	WALKING,
	RISING,
	FALLING,
	SLOPEFALL,
}

const bulletPath = preload('res://scenes/actors/player/Bullet.tscn')
const SPEED_CAP = 80000

var JUMP_FORCE: int = PlayerSingleton.JUMP_FORCE
var MAX_SPEED: int = PlayerSingleton.MAX_SPEED
var ACCELERATION: int = PlayerSingleton.ACCELERATION
var FRICTION: int = PlayerSingleton.FRICTION
var GRAVITY: int = PlayerSingleton.GRAVITY
var MAX_AMMO: int = PlayerSingleton.MAX_AMMO

@onready var animatedSprite = $AnimatedSprite2D
@onready var gunTimer = $GunTimer
@onready var slopeTimer = $SlopeTimer
@onready var shotgunFire = $SFX/ShotgunFire
@onready var shotgunReload = $SFX/ShotgunReload

var AMMO = 0
var cursorVector = Vector2.ZERO
var onSlope = false
var currentState = STATES.IDLE
var input = Vector2.ZERO

func _ready() -> void:
	animatedSprite.play("idle")
	Game.UI.set_max_shells(MAX_AMMO)
	Game.player = self

func _physics_process(delta) -> void:
	#Handling slopes
	if is_on_floor():
		if rad_to_deg(get_floor_angle()) > 44:
			onSlope = true
		else:
			onSlope = false

	input = Vector2.ZERO
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	apply_gravity()
	do_movement(input.x)
	do_animation(delta)
	shoot_and_reload()
	
	if Input.is_action_pressed("ui_accept"):
		get_tree().reload_current_scene()
	
	move_and_slide()

## Does animation logic
func do_animation(delta) -> void:
	animatedSprite.flip_h = false if get_last_motion().x > 0 else true
	if onSlope:
		animatedSprite.play("roll")
		$AnimatedSprite2D.rotation += clampf(sign(velocity.x) * velocity.length() / 10, -16, 16) * delta
	else:
		$AnimatedSprite2D.rotation = 0
		if is_on_floor():
			if input.x != 0:
				animatedSprite.play("walk")
			else:
				animatedSprite.play("idle")
		else:
			if velocity.y > 0:
				animatedSprite.play("falling")
				$AnimatedSprite2D.rotation_degrees = -clampf(velocity.x / 10, -45, 45)
			else:
				animatedSprite.play("rising")

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
	velocity += get_local_mouse_position().normalized() * JUMP_FORCE
	shotgunFire.play()
	for _i in range(10):
		var bullet = bulletPath.instantiate()
		Game.world.projectiles.add_child(bullet)
		bullet.global_position = $Marker2D.global_position
		bullet.rotation = get_local_mouse_position().angle()
		var randomBulletSpeed = Vector2(2000 + randf_range(-400, 400), 0)
		var randomAngle = get_local_mouse_position().angle() + randf_range(-0.25, 0.25)
		bullet.apply_impulse(randomBulletSpeed.rotated(randomAngle), Vector2.ZERO)
	gunTimer.start(0.25)
	AMMO -= 1
	Game.UI.set_shells(AMMO)

## Handles if player is able to shoot and reloads gun on the ground
func shoot_and_reload() -> void:
	if AMMO > 0:
		if gunTimer.is_stopped() and Input.is_action_just_pressed("mouse1"):
			shoot()
	if  AMMO < MAX_AMMO and is_on_floor() and gunTimer.is_stopped() and not onSlope:
		shotgunReload.play()
		AMMO = MAX_AMMO
		Game.UI.reload_shells()

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
			velocity.x = move_toward(velocity.x, get_floor_normal().x * SPEED_CAP, FRICTION)
			velocity.y = move_toward(velocity.y, 1 * SPEED_CAP, GRAVITY)

## Handles giving the player shells.
func add_shells(x: int) -> void:
	Game.UI.add_shells(x)
	AMMO += x
	shotgunReload.play()

func set_max_shells(x: int) -> void:
	MAX_AMMO = x
	Game.UI.set_max_shells(x)
