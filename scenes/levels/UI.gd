extends Control

const SHELL_EMPTY_SPRITE = preload("res://assets/uisprites/shellempty.png")
const SHELL_SPRITE = preload("res://assets/uisprites/shell.png")
const SHELL_PROJECTILE = preload("res://scenes/spent_shell.tscn")

var shake_amp := 1
var shake_frame_freq := 3
var shake_starting_frames := 4
var shake_frames_left := 4
var shake_frames_track := 0
var shaking := false

@onready var margin = $UIMargin
@onready var shell_container = $UIMargin/ShellContainer

func _ready():
	set_max_shells(2)

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

func reload_shells() -> void:
	for shell_icon in shell_container.get_children():
		shell_icon.texture = SHELL_SPRITE

func set_max_shells(x: int) -> void:
	pass

func shake_ui(amp: int, freq: int, length: int) -> void:
	shake_amp = amp
	shake_frame_freq = freq
	shake_starting_frames = length
	shake_frames_left = length
	shake_frames_track = 0
	shaking = true

func _physics_process(_delta) -> void:
	if shaking:
		shake_frames_track += 1
		if shake_frames_track > shake_frame_freq:
			shake_frames_left -= 1
			shake_frames_track = 0
			var shake_x = randf_range(-shake_amp, shake_amp)
			var shake_y = randf_range(-shake_amp, shake_amp)
			var shake_mult = float(shake_frames_left) / float(shake_starting_frames)
			margin.add_theme_constant_override("margin_bottom", 8 + shake_x * shake_mult)
			margin.add_theme_constant_override("margin_left", 8 + shake_y * shake_mult)
			if shake_frames_left <= 0:
				shaking = false
