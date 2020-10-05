extends Control

func set_timescore(timescore: int):
	$Label.text = str(timescore)

func setvalue(timescore_gains):
	$Label2.visible = true
	if (timescore_gains > 0):
		$Label2.text = "+" + str(round(timescore_gains))
		$Label2.modulate = Color("#396A28")
	elif timescore_gains < 0:
		$Label2.modulate = Color("#B61817")
		$Label2.text = str(round(timescore_gains))
	else:
		$Label2.visible = false
		return
	yield(get_tree().create_timer(4), "timeout")
	$Label2.visible = false
	return
