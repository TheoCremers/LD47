extends KinematicBody2D

const UP = Vector2(0, -1)
const MAX_SPEED_X = 28000
const MAX_JUMP_HEIGHT = 80
const AIR_CONTROL = 0.6
const ACCELERATION = 54000
const DECELERATION = 82000
const DECELETATION_SLIDE = 10000
const JUMP_FORCE_X = 10000 
const JUMP_FORCE_Y = 24000 
const DASH_FORCE_X = 77000 
const DASH_FORCE_Y = 48000 
const GRAVITY = 100000 

const BOMB_UP = Vector2(0, -400)
const BOMB_DIAG = Vector2(400, -400)
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

onready var bomb = preload("res://scenes/Translocation_bomb.tscn")

func _ready():
	# Ensure the first frame is displayed correctly
	velocity = -UP*10
	velocity = move_and_slide(velocity, UP)
	pass

func _input(event):
	if stunned:
		return
	if event.is_action_released("jump"):
		jump_state = false
	if event.is_action_pressed("jump"):
		if on_floor:
			jump_trigger = true
		pass
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
	jump_state = true
	_play_sound(JUMP)
	pass

func _frame_input():
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
	if (not $DashCooldown.time_left):
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
	# TODO: Dash trail/animation
	pass


func _dash_mechanics(delta):
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
		$Animation.play("Falling")
		return
	
	if (velocity.y < 0):
		$Animation.play("Jumping")
	else:
		$Animation.play("Falling")
	
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
	# When hitting an obstacle, causing the velocity to cease, re-adjust the speed
	if (is_on_wall()):
		speed_x = 0

	if input_direction:
		if (facing_direction == -input_direction):
			speed_x /= 3
		facing_direction = input_direction
		speed_x += ACCELERATION * delta
		
		# Change animation speed based on movement speed
		$Animation.frames.set_animation_speed("Walking", 7 + (9 * (speed_x / MAX_SPEED_X)))
		$Animation.play("Walking")
	else:
		speed_x -= DECELERATION * delta
		if (velocity.x == 0):
			if ($Animation.animation == "Falling" or $Animation.animation == "Landing"):
				$Animation.play("Landing")
			else:
				$Animation.play("Idle")
		pass
	pass

func _bomb_action():
	if active_bomb:
		position = bomb_instance.position
		bomb_instance.on_trigger()
		active_bomb = false
	else:
		if has_bomb:
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
			
			bomb_instance = bomb.instance()
			bomb_instance.position = position
			bomb_instance.linear_velocity = bomb_velocity
			get_parent().add_child(bomb_instance)
	pass

func knockback(new_velocity, stun_time):
	velocity = new_velocity
	facing_direction = -sign(new_velocity.x)
	stunned = true
	stun_remaining = stun_time
	pass

func _play_sound(index):
	if(index == RUN):
		if(!get_node("runSound").is_playing()):
			get_node("runSound").play()
	elif(index == DEATH):
		get_node("deathSound").play()
	elif(index == JUMP):
		get_node("jumpSound").play()
	pass
