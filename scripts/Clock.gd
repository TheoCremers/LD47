extends Label

const SOUNDSTARTS = 3
var timeRemaining = 20

export (Color, RGB) var text_color
var timeStarted = false
var previousNum = 999999

# Called when the node enters the scene tree for the first time.
func _ready():
	set_modulate(text_color)
	_startTime()
	pass # Replace with function body.
	
func start(maxtime: int):
	_setTime(maxtime)
	_startTime()
	
func _physics_process(delta):
	var pointLoc = str(timeRemaining).find('.')
	var decimal = str(timeRemaining).substr(pointLoc+1,1)
	var currentNum = int(str(timeRemaining).substr(0, pointLoc))
	text = ("%02d:%s" % [timeRemaining, decimal])
	if timeStarted == true:
		_subtractTime(delta)
		
	if timeRemaining <= SOUNDSTARTS:
		if currentNum < previousNum:
			AudioManager.play_sfx("TimerCountdown")
			pass
		pass
		
	_check_time_remaining()
	previousNum = currentNum;
	pass

func time_penalty(amount):
	_subtractTime(amount)
	AudioManager.play_sfx("TimerCountdown")
	_check_time_remaining()
	pass

func time_bonus(amount):
	_addTime((amount))
	# TODO gain sound
	pass

func _check_time_remaining():
	if timeRemaining <= 0:
		_stopTime()
		_setTime(0.0)
		AudioManager.play_sfx("TimerZero")
		get_tree().call_group("game", "time_up")

func _startTime():
	timeStarted = true
	pass
	
func _stopTime():
	timeStarted = false
	pass
	
func _setTime(value):
	timeRemaining = value
	pass
	
func _addTime(value):
	timeRemaining = clamp(timeRemaining + value, 0, 99)
	pass
	
func _subtractTime(value):
	timeRemaining = clamp(timeRemaining - value, 0, 99)
	pass

