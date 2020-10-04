extends Node2D

onready var debug_gui_scene = preload("res://scenes/gui/DebugGUI.tscn")
onready var general_gui_scene = preload("res://scenes/gui/GeneralGUI.tscn")
var general_gui
var debug_gui

var timescore: float = 0

func _ready():
	add_to_group("game")
	
	# Init things
	general_gui = general_gui_scene.instance()
	debug_gui = debug_gui_scene.instance()
	$Overhead.add_child(debug_gui)
	$Overhead.add_child(general_gui)
	
	load_room("Room1")
	pass
	
func load_room(name: String):
	var current_room = get_current_room()
	if (current_room != null):
		increment_timescore(current_room)
		self.remove_child(current_room)
		current_room.queue_free()
	var new_room = load("res://scenes/rooms/" + name + ".tscn").instance()
	self.add_child(new_room)
	return true
	
func increment_timescore(current_room):
	timescore += current_room.get_node("Clock/Clock").timeRemaining
	general_gui.set_timescore(int(round(timescore)))
	pass

func get_current_room():
	if self.has_node("Room"):
		return self.get_node("Room")
	return null
	
func room_transition(name: String, entrance: Vector2):
	# Animation fadeout
	get_tree().paused = true
	yield(get_tree().create_timer(0.25), "timeout")
	$Overhead/RoomTransition.position = entrance
	$Overhead/RoomTransition.visible = true
	
	$Tween.interpolate_property($Overhead/RoomTransition, "scale", \
	Vector2.ZERO, Vector2(5,5), 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.start()
	yield($Tween, "tween_completed")
	
	# Transition
	load_room(name)
	
	# Animation fadein
	yield(get_tree().create_timer(0.25), "timeout")
	$Overhead/RoomTransition.position = get_viewport_rect().size / 2

	$Tween.interpolate_property($Overhead/RoomTransition, "scale", \
	$Overhead/RoomTransition.scale, Vector2.ZERO, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	
	$Tween.start()
	yield($Tween, "tween_completed")
	$Overhead/RoomTransition.visible = false
	get_tree().paused = false
