extends RigidBody2D

var explosion = preload("res://scenes/effects/Explosion.tscn")
# Give this a velocity by setting the body.linear_velocity = Vector(x, y)

func _ready():
	linear_velocity = Vector2(400, -200)
	pass

func _physics_process(delta):
	 pass

func on_trigger():
	#explosion
	var new_explosion = explosion.instance()
	new_explosion.position = global_position
	
	#delete object
	pass
