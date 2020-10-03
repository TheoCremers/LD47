extends Node2D

onready var player = $"/root/Game/Player"

var facing_direction = 1

func _ready():
	pass

func _process(delta):
	facing_direction = sign(player.global_position.x - global_position.x)
	scale.x = facing_direction
