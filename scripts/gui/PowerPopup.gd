extends Control

var read = false

func _ready():
	get_tree().paused = true
	yield(get_tree().create_timer(2), "timeout")
	read = true
	pass 
	
func _input(_event):
	if (read):
		get_tree().paused = false
		queue_free()
	pass
