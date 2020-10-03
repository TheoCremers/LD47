extends Label

export (Color, RGB) var text_color

func _ready():
	set_modulate(text_color)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
