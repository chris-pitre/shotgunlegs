extends Node

signal moved_player

var JUMP_FORCE: int = -500
var MAX_SPEED: int = 60
var ACCELERATION: int = 10
var FRICTION: int = 40
var GRAVITY: int = 20
var MAX_AMMO: int = 1

func _change_player_position(player_x: int, player_y: int) -> void:
	emit_signal("moved_player", player_x, player_y)
