extends Node2D

var debug_gui_scene = preload("res://scenes/gui/DebugGUI.tscn")
var general_gui_scene = preload("res://scenes/gui/GeneralGUI.tscn")

export (String) var StartRoom = "Room1"

const TIME_PENALTY: int = 10

var general_gui
var debug_gui
var current_room_scene

func _ready():
	add_to_group("Room_up1")
	
	# Init things
	general_gui = general_gui_scene.instance()
	#debug_gui = debug_gui_scene.instance()
	#$Overhead.add_child(debug_gui)
	$Overhead.add_child(general_gui)
	AudioManager.play_bgm("FirstLoop")
	
	load_room(StartRoom)
	
	# Give player Translocator power
	Progression.transloc_level = 1
	Progression.dash_unlocked = true
	pass
	
func load_room(name: String):
	var current_room = get_current_room()
	if current_room != null:
		if current_room.max_time > 0:
			increment_timescore(current_room)
		self.remove_child(current_room)
		current_room.queue_free()
	current_room_scene = load("res://scenes/rooms/" + name + ".tscn")
	var new_room = current_room_scene.instance()
	self.add_child(new_room)
	return true

func reset_room():
	Progression.timescore = max(Progression.timescore - TIME_PENALTY, 0)
	general_gui.set_timescore(int(round(Progression.timescore)))
	var current_room = get_current_room()
	self.remove_child(current_room)
	current_room.queue_free()
	var new_room = current_room_scene.instance()
	self.add_child(new_room)
	
func increment_timescore(current_room):
	Progression.timescore += current_room.get_node("Clock/Clock").timeRemaining
	general_gui.set_timescore(int(round(Progression.timescore)))
	pass

func get_current_room():
	if self.has_node("Room"):
		return self.get_node("Room")
	return null
	
func room_transition(name: String, entrance: Vector2):
	print("ok")
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

func time_up():
	# Animation fadeout
	get_tree().paused = true
	yield(get_tree().create_timer(0.25), "timeout")
	$Tween.interpolate_property($Overhead/FadeToBlack, "modulate:a", \
	0, 1, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.start()
	yield($Tween, "tween_completed")
	
	# Restart room
	reset_room()
	
	# Animation fadein
	yield(get_tree().create_timer(0.1), "timeout")
	$Tween.interpolate_property($Overhead/FadeToBlack, "modulate:a", \
	1, 0, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	get_tree().paused = false
	pass

func get_powerup(name: String):
	match name:
		"dash":
			Progression.dash_unlocked = true
		"translocator":
			Progression.transloc_level += 1
	pass
