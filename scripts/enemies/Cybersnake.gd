extends Node2D

onready var player = $"/root/Game/Player"
onready var sprite = $Sprite
onready var tween = $Tween
onready var timer = $Timer
onready var area = $Area2D

export(float) var attack_delay = 0.1
export(float) var attack_cd = 0.3

var triggered = false
var facing_direction = 1

func _ready():
	pass

func _process(delta):
	if not triggered:
		facing_direction = sign(player.global_position.x - global_position.x)
		scale.x = facing_direction

func _on_attack_area_entered(body):
	if not triggered:
		triggered = true
		# telegraph attack
		tween.interpolate_property(sprite, "modulate", Color.white, Color(1, 0, 0), attack_delay, Tween.TRANS_SINE, Tween.EASE_IN)
		tween.start()

func _on_attack_warning_completed(object, key):
	# TODO attack animation
	if(area.overlaps_body(player)):
		# TODO damage/kill the player
		pass
	# turn back color and start cd
	sprite.modulate = Color.white
	timer.wait_time = attack_cd
	timer.start()
	yield(timer, "timeout")
	triggered = false
