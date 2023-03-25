extends Node2D

@onready var transition = $Transition
@onready var current_scene = $CurrentScene

var next_scene: PackedScene = null

func _ready():
	SceneManagerSingleton.connect("changed_area", _change_current_scene)

func _change_current_scene(scene: PackedScene):
	transition.change_scene()
	next_scene = scene

func _on_transition_anim_finished():
	if next_scene != null:
		current_scene.get_child(0).queue_free()
		current_scene.add_child(next_scene.instantiate())
		next_scene = null
