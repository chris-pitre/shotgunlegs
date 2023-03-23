extends Camera2D

var cursorVector = Vector2()

func _process(delta):
	position = get_local_mouse_position() / 6
