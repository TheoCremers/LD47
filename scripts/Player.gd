extends KinematicBody2D

const UP = Vector2(0, -1)
const MAX_SPEED_X = 30000 
const MAX_JUMP_HEIGHT = 80
const AIR_CONTROL = 0.5
const ACCELERATION = 48000
const DECELERATION = 180000 
const JUMP_FORCE_X = 12000 
const JUMP_FORCE_Y = 32000 
const DASH_FORCE_X = 77000 
const DASH_FORCE_Y = 48000 
const GRAVITY = 170000 

var input_direction = 0
var facing_direction = 1
var speed_x = 0
var velocity = Vector2()
var dash_trigger = false
var jump_trigger = false
var jump_state = false
var jump_init_position = 0
var on_floor = false

func _ready():
	# Ensure the first frame is displayed correctly
	velocity = -UP*10
	velocity = move_and_slide(velocity, UP)
	pass

func _input(event):
	if event.is_action_released("jump"):
		jump_state = false
	if event.is_action_pressed("jump"):
		if on_floor:
			jump_trigger = true
		pass
	_dash_input(event)
	pass

func _physics_process(delta):
	on_floor = is_on_floor()
	_frame_input()
	_movement_and_animation(delta)
	pass

func _jump(delta):
	velocity.y = -(JUMP_FORCE_Y * delta)
	jump_init_position = position.y
	jump_trigger = false
	jump_state = true
	pass

func _frame_input():
	if not is_processing_input():
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
	
	speed_x = clamp(speed_x, 0, MAX_SPEED_X)
	velocity.x = speed_x * facing_direction * delta
	velocity = move_and_slide(velocity, UP)	
	pass

func _air_mechanics(delta):
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
	
	# Gravity
	if not is_on_ceiling() and jump_state and ((jump_init_position - MAX_JUMP_HEIGHT) < position.y):
		velocity.y = -(JUMP_FORCE_Y * delta)
	else:
		jump_state = false

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