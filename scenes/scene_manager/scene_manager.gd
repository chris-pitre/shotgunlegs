extends Node2D

@onready var transition = $Transition
@onready var current_scene = $CurrentScene

var next_scene: PackedScene = null
var next_player_x: int = 0
var next_player_y:int = 0

func _ready():
	SceneManagerSingleton.connect("changed_area", _change_current_scene)

func _change_current_scene(scene: PackedScene, player_x: int, player_y: int) -> void:
	transition.change_scene()
	next_scene = scene	
	next_player_x = player_x
	next_player_y = player_y

func _on_transition_anim_finished() -> void:
	if next_scene == current_scene.get_child(0):
		PlayerSingleton._change_player_position(next_player_x, next_player_y)
	elif next_scene != null:
		current_scene.get_child(0).queue_free()	
		current_scene.add_child(next_scene.instantiate())
		next_scene = null
		PlayerSingleton._change_player_position(next_player_x, next_player_y)
	
