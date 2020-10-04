extends Node2D

onready var sprite = $AnimatedSprite
onready var swipe_sprite = $"Area2D/AnimatedAttack"
onready var tween = $Tween
onready var timer = $Timer
onready var area = $Area2D

export(float) var attack_delay = 0.3
export(float) var attack_cd = 0.3
export(Vector2) var knockback = Vector2(-500, -500)
export(float) var stun_time = 0.3

var player
var triggered = false
var facing_direction = 1

func start(_player):
	player = _player
	pass

func _ready():
	sprite.animation = "idle"
	sprite.play()
	pass

func _process(_delta):
	if not triggered and player != null:
		facing_direction = -sign(player.global_position.x - global_position.x)
		scale.x = facing_direction

func _start_attack():
	triggered = true
	# telegraph attack
	sprite.animation = "attacking"
	tween.interpolate_property(sprite, "modulate", Color.white, Color(1, 0, 0), attack_delay, Tween.TRANS_SINE, Tween.EASE_IN)
	tween.start()

func _on_attack_area_entered(_body):
	if not triggered:
		_start_attack()

func _on_attack_warning_completed(_object, _key):
	# TODO attack animation
	swipe_sprite.visible = true
	swipe_sprite.frame = 0
	swipe_sprite.play()
	
	if(area.overlaps_body(player)):
		var knockback_velocity = knockback
		knockback_velocity.x *= facing_direction
		player.knockback(knockback_velocity, stun_time)
		pass
	# turn back color and start cd
	sprite.modulate = Color.white
	timer.wait_time = attack_cd
	timer.start()
	yield(timer, "timeout")
	triggered = false
	sprite.animation = "idle"
	# check if player is still in attack area
	if(area.overlaps_body(player)):
		_start_attack()


func _on_AnimatedAttack_finished():
	swipe_sprite.visible = false
