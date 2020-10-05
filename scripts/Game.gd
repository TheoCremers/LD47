extends Node2D

var debug_gui_scene = preload("res://scenes/gui/DebugGUI.tscn")
var general_gui_scene = preload("res://scenes/gui/GeneralGUI.tscn")

export (String) var StartRoom = "RoomA8"

const TIME_PENALTY: int = 10

var general_gui
var debug_gui
var current_room_scene

func _ready():
	add_to_group("game")
	
	# Init things
	general_gui = general_gui_scene.instance()
	debug_gui = debug_gui_scene.instance()
	$Overhead.add_child(debug_gui)
	$Overhead.add_child(general_gui)
	AudioManager.play_bgm("FirstLoop")
	
	load_room(StartRoom)
	
	# Give player Translocator power
	Progression.transloc_level = 3
	Progression.dash_unlocked = true
	pass
	
func load_room(name: String):
	var current_room = get_current_room()
	if current_room != null:
		if current_room.max_time > 0:
			increment_timescore(current_room)
			if Progression.timescore > 300:
				AudioManager.play_bgm("SecondLoop")
		if current_room.bonus_room_id != 0:
			Progression.clear_bonus_room(current_room.bonus_room_id)
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
	# Animation fadeout
	get_tree().paused = true
	yield(get_tree().create_timer(0.25), "timeout")
	$RoomTransition.position = entrance
	$RoomTransition.visible = true
	
	$Tween.interpolate_property($RoomTransition, "scale", \
	Vector2.ZERO, Vector2(5,5), 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.start()
	yield($Tween, "tween_completed")
	var vtrans = get_canvas_transform()
	var top_left = -vtrans.get_origin() / vtrans.get_scale()
	var vsize = get_viewport_rect().size
	$RoomTransition.position = top_left + 0.5*vsize/vtrans.get_scale()
	
	# Transition
	if (name == "END"):
		AudioManager.fadeout_bgm()
		AudioManager.stop_all_sfx()
		Engine.set_time_scale(1)
		Engine.set_iterations_per_second(60)
		get_tree().paused = false
		assert(get_tree().change_scene("res://scenes/story/Credits.tscn") == OK)
	else:
		load_room(name)
		
	# Animation fadein
	vtrans = get_canvas_transform()
	top_left = -vtrans.get_origin() / vtrans.get_scale()
	vsize = get_viewport_rect().size
	$RoomTransition.position = top_left + 0.5*vsize/vtrans.get_scale()
	$Tween.interpolate_property($RoomTransition, "scale", \
	$RoomTransition.scale, Vector2.ZERO, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)	
	$Tween.start()
	yield($Tween, "tween_completed")
	$RoomTransition.visible = false
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
			var popup_scene = load("res://scenes/gui/PowerPopup.tscn")
			var popup = popup_scene.instance()
			$Overhead.add_child(popup)
			Progression.dash_unlocked = true
		"translocator":
			var popup_scene = load("res://scenes/gui/PowerPopup" 
			+ str(min(4, Progression.transloc_level + 2)) + ".tscn")
			var popup = popup_scene.instance()
			$Overhead.add_child(popup)
			Progression.transloc_level = int(min(Progression.transloc_level + 1, 3))
	pass
