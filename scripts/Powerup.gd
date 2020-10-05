extends Area2D

export(String, "dash", "translocator") var PowerupType = "dash"

func _ready():
	if PowerupType == "dash":
		$Sprite.play("dash")
	else: 
		$Sprite.play("tele")
	assert(connect("body_entered", self, "_on_player_entered") == OK)
	pass # Replace with function body.

func _on_player_entered(_body):
	get_tree().call_group("game", "get_powerup", PowerupType)
	queue_free()
