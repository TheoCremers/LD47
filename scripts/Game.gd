extends Node2D

func _ready():
	add_to_group("game")
	load_room("Room1")
	pass
	
func load_room(name: String):
	var current_room = get_current_room()
	if (current_room != null):
		self.remove_child(current_room)
		current_room.queue_free()
	var new_room = load("res://scenes/rooms/" + name + ".tscn").instance()
	self.add_child(new_room)
	return true

func get_current_room():
	if self.has_node("Room"):
		return self.get_node("Room")
	return null
	
func room_transition(name: String, entrance: Vector2):
	get_tree().paused = true
	$Overhead/RoomTransition.position = entrance
	$Overhead/RoomTransition.visible = true
	$Tween.interpolate_property($Overhead/RoomTransition, "scale", Vector2.ZERO, Vector2(5,5), 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.start()
	yield($Tween, "tween_completed")
	load_room(name)
	yield(get_tree().create_timer(0.25), "timeout")
	$Overhead/RoomTransition.position = get_viewport_rect().size / 2
	$Tween.interpolate_property($Overhead/RoomTransition, "scale", $Overhead/RoomTransition.scale, Vector2.ZERO, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	$Overhead/RoomTransition.visible = false
	get_tree().paused = false
