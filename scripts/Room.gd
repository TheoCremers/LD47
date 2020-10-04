extends Node

export (int) var max_time = 30
export (Vector2) var dimensions = Vector2(512, 320)
export (int) var bonus_room_id = 0
onready var clock_scene = preload("res://scenes/Clock.tscn")

func _ready():
	var player = load("res://scenes/Player.tscn").instance()
	if (max_time > 0):
		var clock = clock_scene.instance()
		add_child(clock)
		get_tree().call_group("clock", "start", max_time)
		
	player.set_position($Startpoint.get_position())
	player.init_camera(dimensions)
	add_child(player)
	get_tree().call_group("enemies", "start", player)
	pass
