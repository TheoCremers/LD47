extends Label

export (Color, RGB) var text_color

var timeRemaining = 7
var timeStarted = false
var previousNum = 999999

# Called when the node enters the scene tree for the first time.
func _ready():
	set_modulate(text_color)
	_startTime()
	pass # Replace with function body.
	
func _physics_process(delta):
	var pointLoc = str(timeRemaining).find('.')
	var decimal = str(timeRemaining).substr(pointLoc+1,1)
	var currentNum = int(str(timeRemaining).substr(0, pointLoc))
	text = ("%02d:%s" % [timeRemaining, decimal])
	if timeStarted == true:
		_subtractTime(delta)
	if timeRemaining <= 3:
		if currentNum < previousNum:
			playSound()
			pass
		pass
	if timeRemaining < 0:
		_stopTime()
		_setTime(0.0)
		pass
	previousNum = currentNum;
	pass

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
	timeRemaining += value
	pass
	
func _subtractTime(value):
	timeRemaining -= value
	pass
	
func playSound():
	get_node("ClockSound").play()	
	pass
