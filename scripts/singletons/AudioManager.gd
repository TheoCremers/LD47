extends Control

var _current_bgm 

func _ready():
	pass

func play_sfx(name):
	$"SFX".get_node(name).play()
	pass

func play_bgm(name):
	if (_current_bgm != null):
		fadeout_bgm()
	_current_bgm = name
	$"BGM".get_node(name).play()
	pass
	
func fadeout_bgm():
	var current_song = $"BGM".get_node(_current_bgm)
	var current_db = current_song.volume_db
	$Tween.interpolate_property(current_song, "volume_db", current_db, \
	current_db -30, 2.0, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	current_song.stop()
	current_song.volume_db = current_db
	pass

func stop_sfx(name):
	$"SFX".get_node(name).stop()
	pass

func stop_all_bgm():
	for node in $"BGM".get_children():
		node.stop()
		pass
	pass

func stop_all_sfx():
	for node in $"SFX".get_children():
		node.stop()
		pass
	pass
