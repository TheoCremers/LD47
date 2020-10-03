extends Area2D

export (String) var NextRoomName

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(connect("body_entered", self, "_on_player_entered") == OK)
	pass # Replace with function body.

func _on_player_entered(_body):
	get_tree().call_group("game", "room_transition", NextRoomName, position)
