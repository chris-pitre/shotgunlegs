extends CanvasLayer

const SHELL_EMPTY_SPRITE = preload("res://assets/uisprites/shellempty.png")
const SHELL_SPRITE = preload("res://assets/uisprites/shell.png")
const SHELL_PROJECTILE = preload("res://scenes/spent_shell.tscn")
const SHELL_INDICATOR = preload("res://scenes/shellindicator.tscn")

var shake_amp := 1
var shake_frame_freq := 3
var shake_starting_frames := 4
var shake_frames_left := 4
var shake_frames_track := 0
var shaking := false
var time = 58456.0

@onready var shake = $UI/UIMargin/Shake
@onready var shell_container = $UI/UIMargin/Shake/ShellContainer
@onready var timer = $UI/UIMargin/TimerLabel

func _ready() -> void:
	Game.UI = self

func _physics_process(delta) -> void:
	#Debug stuff
	$DebugUI/DebugMargin/Panel/VBoxContainer/VelocityDebug.text = "Velocity: %s" % str(Game.player.velocity)
	$DebugUI/DebugMargin/Panel/VBoxContainer/SlopeDebug.text = "Slope: %s" % str(Game.player.onSlope)
	$DebugUI/DebugMargin/Panel/VBoxContainer/SteepnessDebug.text = "Steepness: %s" % str(rad_to_deg(Game.player.get_floor_angle()))
	$DebugUI/DebugMargin/Panel/VBoxContainer/AmmoDebug.text = "Ammo: %s" % str(Game.player.AMMO)
	$DebugUI/DebugMargin/Panel/VBoxContainer/OnFloorDebug.text = "On Floor: %s" % str(Game.player.is_on_floor())
	$DebugUI/DebugMargin/Panel/VBoxContainer/OnWallDebug.text = "On Wall: %s" % str(Game.player.is_on_wall())
	$DebugUI/DebugMargin/Panel/VBoxContainer/FPS.text = "FPS: %s" % Engine.get_frames_per_second()
	#UI Shaking - Only control nodes in the "Shake" node get shook.
	if shaking:
		shake_frames_track += 1
		if shake_frames_track > shake_frame_freq:
			shake_frames_left -= 1
			shake_frames_track = 0
			var shake_x = randf_range(-shake_amp, shake_amp)
			var shake_y = randf_range(-shake_amp, shake_amp)
			var shake_mult = float(shake_frames_left) / float(shake_starting_frames)
			shake.add_theme_constant_override("margin_bottom", 8 + shake_x * shake_mult)
			shake.add_theme_constant_override("margin_left", 8 + shake_y * shake_mult)
			if shake_frames_left <= 0:
				shaking = false
	#Timer
	time += delta
	timer.text = format_num_to_time(time)

## Function to handle setting amount of ammo left for UI
func set_shells(x: int) -> void:
	shake_ui(8, 1, 16)
	for shell_icon in shell_container.get_children():
		if int(shell_icon.name.right(1)) <= x:
			shell_icon.texture = SHELL_SPRITE
		else:
			if shell_icon.texture != SHELL_EMPTY_SPRITE:
				var new_shell_projectile = SHELL_PROJECTILE.instantiate()
				add_child(new_shell_projectile)
				new_shell_projectile.global_position = shell_icon.global_position + Vector2(8, 24)
			shell_icon.texture = SHELL_EMPTY_SPRITE

## Function to handle setting max ammo to be held for UI
func set_max_shells(x: int) -> void:
	for child in shell_container.get_children():
		child.queue_free()
	for i in range(x):
		var new_shell_indicator = SHELL_INDICATOR.instantiate()
		shell_container.add_child(new_shell_indicator)
		new_shell_indicator.name = "Shell%s" % str(i + 1)

## Reloads shells
func reload_shells() -> void:
	for shell_icon in shell_container.get_children():
		shell_icon.texture = SHELL_SPRITE

## Gives UI a shaking effect
func shake_ui(amp: int, freq: int, length: int) -> void:
	shake_amp = amp
	shake_frame_freq = freq
	shake_starting_frames = length
	shake_frames_left = length
	shake_frames_track = 0
	shaking = true

func format_num_to_time(x: float) -> String:
	var seconds = fmod(x, 60.0)
	var minutes = fmod(x / 60.0, 60.0)
	var hours = floori((x / 60.0) / 60.0)
	
	return "%d:%02d:%05.2f" % [hours, minutes, seconds]
