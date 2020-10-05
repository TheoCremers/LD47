extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Ones.emitting = true
	$Zeroes.emitting = true
	$Timer.connect("timeout", self, "_is_done")
	pass # Replace with function body.

func _is_done():
	queue_free()
