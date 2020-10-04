extends Label

var amount = 0

func _ready():
	text = "-" + str(round(amount)) + " SEC"
	$PositionTween.interpolate_property(self, "rect_position", rect_position,
	rect_position + Vector2(0, -100), 1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$PositionTween.start()
	
	$VisibilityTween.interpolate_property(self, "modulate:a", 1.0,
	0.0, 1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$VisibilityTween.start()

func _on_VisibilityTween_tween_all_completed():
	call_deferred('free')
