extends KinematicBody2D

const UP = Vector2(0, -1)
const MAX_SPEED_X = 18000
const MAX_JUMP_HEIGHT = 80
const AIR_CONTROL = 0.6
const ACCELERATION = 54000
const DECELERATION = 82000
const DECELETATION_SLIDE = 10000
const JUMP_FORCE_X = 10000 
const JUMP_FORCE_Y = 24000 
const DASH_FORCE_X = 30000
const GRAVITY = 100000 

const BOMB_UP = Vector2(0, -350)
const BOMB_DIAG = Vector2(200, -250)
const BOMB_HORI = Vector2(400, -100)

const RUN = 1
const DEATH = 2
const JUMP = 3

var input_direction = 0
var facing_direction = 1
var speed_x = 0
var velocity = Vector2()
var dash_trigger = false
var jump_trigger = false
var jump_state = false
var jump_init_position = 0
var on_floor = false
var has_bomb = true
var active_bomb = false
var bomb_instance
var stunned = false
var stun_remaining = 0
var dying = false
var has_moved = false

onready var bomb = preload("res://scenes/Translocation_bomb.tscn")
onready var timeloss = preload("res://scenes/effects/TimeLoss.tscn")
onready var telecheck_scene = preload("res://scenes/Telecheck.tscn")
onready var dash_hitbox = $DashAttackArea/CollisionShape2D

func _ready():
	$Animation.animation = "Idle"
	# Ensure the first frame is displayed correctly
	velocity = -UP*10
	velocity = move_and_slide(velocity, UP)
	# disable dashattack hitbox
	dash_hitbox.set_disabled(true)
	assert($Animation.connect("animation_finished",self,"_animation_finished") == OK)
	assert($BombCooldown.connect("timeout",self,"_on_bombcooldown_finished") == OK)
	assert($DashActive.connect("timeout", self, "_on_dash_finished") == OK)
	pass

func init_camera(bounding_box: Vector2):
	$Camera2D.limit_right = bounding_box.x
	$Camera2D.limit_bottom = bounding_box.y

func _input(event):
	has_moved = true
	if stunned:
		return
	
	_dash_input(event)
	if event.is_action_pressed("throw_bomb"):
		_bomb_action()
	pass

func _physics_process(delta):
	on_floor = is_on_floor()
	_frame_input()
	_movement_and_animation(delta)
	
	if stunned:
		stun_remaining -= delta
		if stun_remaining <= 0:
			stunned = false
			speed_x = abs(velocity.x)
	pass

func _jump(delta):
	velocity.y = -(JUMP_FORCE_Y * delta)
	jump_init_position = position.y
	jump_trigger = false
	jump_state = Input.is_action_pressed("jump")
	_play_sound(JUMP)
	pass

func _frame_input():
	if Input.is_action_just_released("jump"):
		jump_state = false
	if Input.is_action_just_pressed("jump"):
		if on_floor:
			jump_trigger = true
		else:
			$JumpBuffer.start()
		pass
	elif !$JumpBuffer.is_stopped() and on_floor:
		jump_trigger = true
		$JumpBuffer.stop()
		
	if not is_processing_input():
		return
	
	if stunned:
		input_direction = 0
		return
	
	var move_left = Input.is_action_pressed("move_left")
	var move_right = Input.is_action_pressed("move_right")
	
	# TODO: Implement up direction for translocator aiming
	if move_left == move_right:
		input_direction = 0
	elif move_left:
		input_direction = -1
	elif move_right:
		input_direction = 1
	if is_on_floor() && input_direction != 0:
		_play_sound(RUN)

func _movement_and_animation(delta):
	if jump_trigger:
		_jump(delta)
	if dash_trigger:
		_dash_trigger(delta)
	if $DashActive.time_left:
		_dash_mechanics(delta)
	else:
		# When hitting an obstacle, causing the velocity to cease, re-adjust the speed
		if (is_on_wall()):
			speed_x = 0
		if on_floor:
			_ground_mechanics(delta)
		else:
			_air_mechanics(delta)
		_movement_mechanics(delta)
		pass


func _dash_input(event):
	if event.is_action_pressed("dash_modifier"):
		dash_trigger = true
	pass


func _dash_trigger(_delta):
	dash_trigger = false
	if not $DashCooldown.time_left and Progression.dash_unlocked:
		if input_direction or facing_direction:
			_dash()
		pass
	pass

func _dash():
	# TODO: SFX
	if (input_direction):
		facing_direction = input_direction
	speed_x = DASH_FORCE_X
	$DashCooldown.start()
	$DashActive.start()
	# Dash attack
	$DashAttackArea.scale.x = facing_direction
	dash_hitbox.set_disabled(false)
	# TODO: Dash trail/animation
	_play_animation("Dashing")
	pass


func _dash_mechanics(delta):
	# When hitting an obstacle, causing the velocity to cease, re-adjust the speed
	if (is_on_wall()):
		speed_x = 0
		_stop_dash()
	
	_apply_gravity(delta)
	speed_x = clamp(speed_x, 0, DASH_FORCE_X)
	velocity.x = speed_x * facing_direction * delta
	jump_state = false
	if (on_floor):
		velocity = move_and_slide(Vector2(velocity.x, velocity.y), UP)
	else:
		# While gravity is still applied, it is ignored during an airdash 
		velocity = move_and_slide(Vector2(velocity.x, 0), UP)
	pass

func _on_dash_finished():
	dash_hitbox.set_disabled(true)

func _apply_gravity(delta):
	velocity.y += GRAVITY * delta * delta
	velocity.y = clamp(velocity.y, -((GRAVITY * delta) / 3), ((GRAVITY * delta) / 3))
	pass

func _movement_mechanics(delta):
	if facing_direction == -1:
		$Animation.flip_h = true
		pass
	elif facing_direction == 1:
		$Animation.flip_h = false
		pass
	pass
	_apply_gravity(delta)
	
	if stunned:
		velocity.x = velocity.x * 0.9
	else:
		speed_x = clamp(speed_x, 0, MAX_SPEED_X)
		velocity.x = speed_x * facing_direction * delta
	velocity = move_and_slide(velocity, UP)
	
	pass

func _air_mechanics(delta):
	# Gravity
	if not is_on_ceiling() and jump_state and ((jump_init_position - MAX_JUMP_HEIGHT) < position.y):
		velocity.y = -(JUMP_FORCE_Y * delta)
	else:
		jump_state = false
	
	if stunned:
		_play_animation("Falling")
		return
	
	if (velocity.y < 0):
		_play_animation("Jumping")
	elif has_moved:
		_play_animation("Falling")
	
	# Airturn
	if (facing_direction == -input_direction):
		speed_x /= 2
	
	# Jump control
	if input_direction:
		facing_direction = input_direction
		speed_x = clamp(speed_x, JUMP_FORCE_X, MAX_SPEED_X)
		speed_x += ACCELERATION * AIR_CONTROL * delta
	else:
		speed_x -= DECELERATION * AIR_CONTROL * delta
	

func _ground_mechanics(delta):
	
	if input_direction:
		if (facing_direction == -input_direction):
			speed_x /= 3
		facing_direction = input_direction
		speed_x += ACCELERATION * delta
		
		# Change animation speed based on movement speed
#		$Animation.frames.set_animation_speed("Walking", (7 + (9 * (speed_x / MAX_SPEED_X)))* 0.5)
#		_play_animation("Walking")
	else:
		speed_x -= DECELERATION * delta
#		if (velocity.y == 0):
#			if ($Animation.animation == "Falling"):
#				_play_animation("Landing")
#		if (velocity.x == 0):
#			if ($Animation.animation != "Falling"):
#				_play_animation("Idle")
		pass
	if (velocity.y == 0):
		if ($Animation.animation == "Falling"):
			_play_animation("Landing")
		elif (abs(velocity.x) > 100):
			# Change animation speed based on movement speed
			$Animation.frames.set_animation_speed("Walking", (7 + (9 * (speed_x / MAX_SPEED_X)))* 0.5)
			_play_animation("Walking")
		else:
			_play_animation("Idle")
	pass

func _bomb_action():
	if Progression.transloc_level == 0:
		return
	if active_bomb:
		# Check which position we can teleport to. To prevent getting
		# stuck in walls.
		var telecheck = telecheck_scene.instance()
		get_parent().add_child(telecheck)
		telecheck.position = bomb_instance.position
		if telecheck.check_up(24) && telecheck.check_down(24):
			position = bomb_instance.position
		elif telecheck.check_up(48):
			position = bomb_instance.position+Vector2(0, -24)
		elif telecheck.check_down(48):
			position = bomb_instance.position+Vector2(0, 24)
			
		telecheck.queue_free()
		bomb_instance.on_trigger()
		active_bomb = false
		$BombCooldown.start(get_bomb_cooldown())
	else:
		if has_bomb:
			# Throw bomb
			_play_animation("Throwing")
			
			has_bomb = false
			active_bomb = true
			var bomb_velocity = Vector2.ZERO
			
			if Input.is_action_pressed("move_up"):
				if input_direction == 0:
					bomb_velocity = BOMB_UP
				else:
					bomb_velocity = BOMB_DIAG
					bomb_velocity.x *= input_direction
			else:
				if input_direction == 0:
					bomb_velocity = BOMB_DIAG
					bomb_velocity.x *= facing_direction
				else:
					bomb_velocity = BOMB_HORI
					bomb_velocity.x *= input_direction
			bomb_velocity.x += velocity.x * 0.3
			
			bomb_instance = bomb.instance()
			bomb_instance.position = position
			bomb_instance.linear_velocity = bomb_velocity
			get_parent().add_child(bomb_instance)
	pass


func get_bomb_cooldown():
	match Progression.transloc_level:
		2: 
			return 10
		3:
			return 5
		_:
			return 99

func _on_bombcooldown_finished():
	has_bomb = true

func _stop_dash():
	$DashActive.stop()
	dash_trigger = false
	dash_hitbox.set_disabled(true)

func knockback(new_velocity, stun_time, time_loss = 3):
	velocity = new_velocity
	facing_direction = -sign(new_velocity.x)
	# stop dash
	_stop_dash()
	# visual effect
	$Tween.stop_all()
	$Tween.interpolate_property($Animation, "modulate", Color.red, \
	Color.white, 0.6, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()
	# Timeloss
	if !stunned:
		get_tree().call_group("clock", "time_penalty", time_loss)
		var new_loss = timeloss.instance()
		new_loss.amount = time_loss
		new_loss.rect_position = position
		get_parent().add_child(new_loss)
	# get stunned
	stunned = true
	stun_remaining = stun_time
	pass

func _play_animation(name):
	if !($Animation.animation == "Throwing" and $Animation.is_playing()) or \
	(name == "Dashing"):
		$Animation.play(name)
	pass
	
func _on_death():
	if (!dying):
		dying = true
		_play_sound(DEATH)
		stunned = true
		stun_remaining = 100
		$Tween.stop_all()
		$Tween.interpolate_property($Animation, "modulate", Color.white, Color.transparent, 0.2, Tween.TRANS_SINE)
		$Tween.start()
		yield($Tween, "tween_completed")
		get_tree().call_group("game", "reset_room")

func _play_sound(index):
	if(index == RUN):
		AudioManager.play_sfx("PlayerStep", false)
	elif(index == DEATH):
		AudioManager.play_sfx("PlayerDeath")
	elif(index == JUMP):
		AudioManager.play_sfx("PlayerJump")
	pass

func _animation_finished():
	$Animation.stop()
