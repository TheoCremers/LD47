extends Control

var intro_finished = false

func _ready():
	$FadeToBlack.visible = true
	#$IntroText/Label.visible = false
	$Tween.interpolate_property($FadeToBlack, "modulate:a", 1, 0, 2, \
	Tween.TRANS_CUBIC, Tween.EASE_IN, 0.3)
	$Tween.start()
	print_text($IntroText/Label.text)
	$BGM.play(3)
	$Tween.interpolate_property($BGM, "volume_db", -80, -12, 4, \
	Tween.TRANS_CUBIC, Tween.EASE_OUT, 0.3)
	$Tween.start()
	$IntroText/Label.text = ""
	yield(get_tree().create_timer(2), "timeout")
	
	
	
func print_text(text: String):
	for letter in range(text.length()):
		yield(get_tree().create_timer(0.04), "timeout")
		if (letter > text.length() - 10):
			yield(get_tree().create_timer(0.10), "timeout")
		$IntroText/Label.text += text[letter]
		
	yield(get_tree().create_timer(4.0), "timeout")
	show_title()

func show_title():
	$IntroText.visible = false
	$TitleScreen.visible = true
	yield(get_tree().create_timer(2.0), "timeout")
	$TitleScreen/PressStart.visible = true

func _input(event):
	if ($TitleScreen/PressStart.visible and !intro_finished 
	and event.is_action_pressed("jump")):
		intro_finished = true
		$Tween.interpolate_property($BGM, "volume_db", -12, -80, 2, \
		Tween.TRANS_CUBIC, Tween.EASE_OUT, 0.3)
		$Tween.interpolate_property($FadeToBlack, "modulate:a", 0, 1, 2, \
		Tween.TRANS_CUBIC, Tween.EASE_OUT, 0.3)
		$Tween.start()
		yield($Tween, "tween_completed")
		
