extends Area2D

func _ready():
	assert(connect("body_entered", self, "_on_body_entered") == OK)


func _on_body_entered(body):
	if body.is_in_group("enemies"):
		body.on_hit()
	pass
