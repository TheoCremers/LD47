extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func check_up(length):
	$RayCastUp.cast_to.y = -length
	$RayCastUp.force_raycast_update()
	return !$RayCastUp.is_colliding()
	
func check_down(length):
	$RayCastDown.cast_to.y = length
	$RayCastDown.force_raycast_update()
	return !$RayCastDown.is_colliding()
