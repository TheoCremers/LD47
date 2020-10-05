extends Node2D

export (float) var rotation_speed = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotation += delta * rotation_speed
	pass
