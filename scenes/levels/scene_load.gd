extends Node2D

@onready var blackout = $Player/Blackout

func _ready():
	blackout.modulate = Color(0, 0, 0, 1)
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_CIRC)
	await tween.tween_property(blackout, "modulate", Color(0, 0, 0, 0), 0.50).finished
	blackout.queue_free()
