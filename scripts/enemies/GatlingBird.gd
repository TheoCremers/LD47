extends KinematicBody2D

export(float) var vx = 60
export(float) var vy = 60
export(float) var bob_freq = 1
export(float) var attack_cd = 0.2
export(Vector2) var contact_knockback = Vector2(-250, -250)
export(float) var contact_stun_time = 0.3
export (float) var facing_direction = 1

var time = 0
var motion = Vector2()
var alert_level = 0
var attack_cd_time = 0
var dying = false
var death_anim_time = 0.5

var player
onready var sprite = $FlipPoint/Sprite
onready var sightline = $FlipPoint/RayCast2D
onready var tween = $Tween
onready var bullet = preload("res://scenes/enemies/Bullet.tscn")

func start(_player):
	player = _player

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.animation = "flap"
	sprite.play()
	$FlipPoint.scale.x = facing_direction
	
	bob_freq = bob_freq * PI
	$FlipPoint/Hitbox.connect("body_entered", self, "_on_player_contact")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if dying:
		return
	
	# movement
	time += delta
	motion.y = cos(time * bob_freq) * vy
	if alert_level == 0 :
		motion.x = -vx * facing_direction
	else:
		motion.x = motion.x * 0.8
	motion = move_and_slide(motion)
	# turnaround trigger
	if sign(motion.x) == 0 and vx != 0 and alert_level == 0:
		facing_direction = -facing_direction
		$FlipPoint.scale.x = facing_direction
	
	# check for player
	sightline.force_raycast_update()
	var body = sightline.get_collider()
	if body == player:
		alert_level = clamp(alert_level + 1, 0, 15)
	else:
		alert_level = clamp(alert_level - 0.1, 0, 15)
	
	if alert_level > 10:
		if attack_cd_time > 0:
			attack_cd_time -= delta
		else:
			_shoot()
	pass

func _shoot():
	var new_bullet = bullet.instance()
	new_bullet.position = $FlipPoint/bulletpoint.global_position
	new_bullet.set_direction(-facing_direction)
	get_parent().add_child(new_bullet)
	attack_cd_time = attack_cd
	pass

func _on_player_contact(_body):
	if _body == player and not dying:
		var knockback_velocity = contact_knockback
		knockback_velocity.x *= -sign(player.position.x - position.x)
		player.knockback(knockback_velocity, contact_stun_time)
	pass

func on_hit():
	if dying:
		return
	
	dying = true
	# dying animation
	var new_effect = load("res://scenes/effects/EnemyDeathAnim.tscn").instance()
	new_effect.position = position
	new_effect.scale *= 0.7
	get_parent().add_child(new_effect)
	
	sprite.animation = "death"
	tween.interpolate_property(sprite, "modulate", Color.white, \
	Color(0, 1, 0, 0), death_anim_time, Tween.TRANS_SINE, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_completed")
	queue_free()
