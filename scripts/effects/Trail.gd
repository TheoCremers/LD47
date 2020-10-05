extends Sprite


func start():
	$Tween.interpolate_property(self, "modulate:a", 0.65, 0, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	pass

func _on_Tween_tween_completed(_object, _key):
	queue_free()
	pass
