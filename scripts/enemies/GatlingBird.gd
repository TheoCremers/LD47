extends KinematicBody2D

export(float) var vx = 60
export(float) var vy = 120
export(float) var bob_freq = 1

var time = 0
var facing_direction = 1
var motion = Vector2()

onready var player = $"/root/Game/Player"
onready var sprite = $Sprite
#onready var tween = $Tween
#onready var timer = $Timer
#onready var area = $Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	bob_freq = bob_freq * PI
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	motion.y = cos(time * bob_freq) * vy
	motion.x = vx
	motion = move_and_slide(motion)
	# turn around trigger
	if sign(motion.x) == 0:
		vx = -vx
	
	facing_direction = sign(player.global_position.x - global_position.x)
	scale.x = facing_direction
	pass
