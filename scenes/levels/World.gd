extends Node2D

@onready var projectiles = $Projectiles

func _ready():
	Game.world = self
