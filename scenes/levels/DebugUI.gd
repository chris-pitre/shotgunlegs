extends Control

@export var player: CharacterBody2D

func _physics_process(_delta):
	$DebugMargin/Panel/VBoxContainer/VelocityDebug.text = "Velocity: %s" % str(player.velocity)
	$DebugMargin/Panel/VBoxContainer/SlopeDebug.text = "Slope: %s" % str(player.onSlope)
	$DebugMargin/Panel/VBoxContainer/SteepnessDebug.text = "Steepness: %s" % str(player.get_steepness())
	$DebugMargin/Panel/VBoxContainer/AmmoDebug.text = "Ammo: %s" % str(player.AMMO)
	$DebugMargin/Panel/VBoxContainer/OnFloorDebug.text = "On Floor: %s" % str(player.is_on_floor())
	$DebugMargin/Panel/VBoxContainer/OnWallDebug.text = "On Wall: %s" % str(player.is_on_wall())
