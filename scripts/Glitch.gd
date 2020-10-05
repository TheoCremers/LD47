extends Area2D

export(float) var time_amount = 10
onready var timegain = preload("res://scenes/effects/TimeGain.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	assert(connect("body_entered", self, "_on_body_entered") == OK)
	pass # Replace with function body.


func _on_body_entered(_body):
	get_tree().call_group("clock", "time_bonus", time_amount)
	var new_gain = timegain.instance()
	new_gain.amount = time_amount
	new_gain.rect_position = position
	get_parent().add_child(new_gain)
	AudioManager.play_sfx("GlitchPickup");
	queue_free()
	pass

