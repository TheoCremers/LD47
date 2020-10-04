extends RigidBody2D

onready var sprite = $AnimatedSprite
onready var swipe_sprite = $"AttackArea2D/AnimatedAttack"
onready var tween = $Tween
onready var timer = $Timer
onready var attack_area = $AttackArea2D

export(float) var attack_delay = 0.3
export(float) var attack_cd = 0.3
export(Vector2) var attack_knockback = Vector2(-500, -500)
export(float) var attack_stun_time = 0.5
export(Vector2) var contact_knockback = Vector2(-250, -250)
export(float) var contact_stun_time = 0.3

var player
var triggered = false
var facing_direction = 1
var dying = false
var death_anim_time = 0.5

func start(_player):
	player = _player
	pass

func _ready():
	sprite.animation = "idle"
	sprite.play()
	assert($Hitbox.connect("body_entered", self, "_on_player_contact") == OK)
	pass

func _process(_delta):
	if not triggered and player != null and !dying:
		facing_direction = sign(player.position.x - position.x)
		sprite.flip_h = (facing_direction == 1)
		attack_area.scale.x = -facing_direction

func _start_attack():
	triggered = true
	# telegraph attack
	sprite.animation = "attacking"
	tween.interpolate_property(sprite, "modulate", Color.white, \
	Color(1, 0, 0), attack_delay, Tween.TRANS_SINE, Tween.EASE_IN)
	tween.start()

func _on_attack_area_entered(_body):
	if not triggered and not dying:
		_start_attack()

func _on_attack_warning_completed(_object, _key):
	if dying:
		return
	
	# attack animation
	swipe_sprite.visible = true
	swipe_sprite.frame = 0
	swipe_sprite.play()
	
	if(attack_area.overlaps_body(player)):
		var knockback_velocity = attack_knockback
		knockback_velocity.x *= facing_direction
		player.knockback(knockback_velocity, attack_stun_time)
	# turn back color and start cd
	sprite.modulate = Color.white
	timer.wait_time = attack_cd
	timer.start()
	yield(timer, "timeout")
	triggered = false
	sprite.animation = "idle"
	# check if player is still in attack area
	if(attack_area.overlaps_body(player)):
		_start_attack()


func _on_AnimatedAttack_finished():
	swipe_sprite.visible = false

func _on_player_contact(_body):
	if _body == player and not dying:
		var knockback_velocity = contact_knockback
		knockback_velocity.x *= facing_direction
		player.knockback(knockback_velocity, contact_stun_time)
	pass

func on_hit():
	if dying:
		return
	
	dying = true
	# dying animation
	sprite.animation = "attacking"
	tween.interpolate_property(sprite, "modulate", Color.white, \
	Color(0, 1, 0, 0), death_anim_time, Tween.TRANS_SINE, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_completed")
	queue_free()
