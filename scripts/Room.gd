extends Node

func _ready():
	var player = load("res://scenes/Player.tscn").instance()
	player.set_position($Startpoint.get_position())
	add_child(player)
	pass
