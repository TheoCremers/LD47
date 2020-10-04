extends Area2D

export (String) var NextRoomName
export (int) var TimescoreRequirement = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(connect("body_entered", self, "_on_player_entered") == OK)
	if (TimescoreRequirement > Progression.timescore):
		$Sprite.set_modulate(Color(1,0,0))
	pass # Replace with function body.

func _on_player_entered(_body):
	if (TimescoreRequirement <= Progression.timescore):
		get_tree().call_group("game", "room_transition", NextRoomName, position)
