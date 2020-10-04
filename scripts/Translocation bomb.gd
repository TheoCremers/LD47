extends RigidBody2D

var explosion = preload("res://scenes/effects/Explosion.tscn")
# Give this a velocity by setting the body.linear_velocity = Vector(x, y)

func _ready():
	pass

func _physics_process(_delta):
	 pass

func on_trigger():
	#explosion
	var new_explosion = explosion.instance()
	new_explosion.position = global_position
	get_parent().add_child(new_explosion)
	queue_free()
	pass
