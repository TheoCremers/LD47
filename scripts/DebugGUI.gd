extends MarginContainer

onready var pos_x_info = $Arrangement/DebugInfo/PlayerXInfo
onready var pos_y_info = $Arrangement/DebugInfo/PlayerYInfo
onready var velocity_x_info = $Arrangement/DebugInfo/VelocityXInfo
onready var velocity_y_info = $Arrangement/DebugInfo/VelocityYInfo
onready var speed_x_info = $Arrangement/DebugInfo/SpeedXInfo
onready var misc_info = $Arrangement/DebugInfo/Misc
onready var misc2_info = $Arrangement/DebugInfo/Misc2
onready var misc3_info = $Arrangement/DebugInfo/Misc3
onready var misc4_info = $Arrangement/DebugInfo/Misc4
onready var fps_info = $Arrangement/DebugInfo/FPSInfo

var mute = false;

func _ready():
	pass

func _process(_delta):
	var player = $"../../Room/Player";
	
	if (player != null):
		pos_x_info.text = str("Player X: ", player.position.x)
		pos_y_info.text = str("Player Y: ", player.position.y)
		velocity_x_info.text = str("Velocity X: ", player.velocity.x)
		velocity_y_info.text = str("Velocity Y: ", player.velocity.y)
		speed_x_info.text = str("Speed X: ", player.speed_x)
		fps_info.text = str("FPS: ", Performance.get_monitor(Performance.TIME_FPS))
		misc_info.text = str("input dir: ", player.input_direction)

func _input(event):
	if event.is_action_pressed("debug_toggle"):
		if (visible):
			visible = false
		else:
			visible = true
	if event.is_action_pressed("debug_reset"):
		_reset()
	if event.is_action_pressed("mute_audio"):
		mute = !mute
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), mute)
	if event.is_action_pressed("exit_game"):
		get_tree().quit()
	pass


func _reset():
	# AudioManager.stop_all_sfx()
	# AudioManager.stop_all_bgm()
	Engine.set_time_scale(1)
	Engine.set_iterations_per_second(60)
	get_tree().paused = false
	var error = get_tree().reload_current_scene()
	if (error != OK):
		print("Errorcode ", error)
	pass
