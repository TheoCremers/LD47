extends Control

export (bool) var skip = false

func _ready():
	if (skip):
		assert(get_tree().change_scene("res://Game.tscn") == OK)
	print_text($IntroText/Label.text)
	$BGM.play(8.5)
	$Tween.interpolate_property($BGM, "volume_db", -80, -12, 4, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0.3)
	$Tween.start()
	$IntroText/Label.text = ""
	
func print_text(text: String):
	for letter in range(text.length()):
		yield(get_tree().create_timer(0.05), "timeout")
		if (letter > text.length() - 5):
			yield(get_tree().create_timer(0.10), "timeout")
		$IntroText/Label.text += text[letter]
		
	yield(get_tree().create_timer(2.0), "timeout")
	show_title()

func show_title():
	$IntroText.visible = false
	$TitleScreen.visible = true
	yield(get_tree().create_timer(2.0), "timeout")
	$TitleScreen/PressStart.visible = true

func _input(_event):
	if ($TitleScreen/PressStart.visible):
		$Tween.interpolate_property($BGM, "volume_db", -12, -80, 2, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0.3)
		$Tween.interpolate_property($FadeToBlack, "modulate:a", 0, 1, 2, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0.3)
		$Tween.start()
		yield($Tween, "tween_completed")
		assert(get_tree().change_scene("res://Game.tscn") == OK)
