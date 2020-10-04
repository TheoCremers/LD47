extends Area2D

var knockback = Vector2(1000, -100)
var stuntime = 0.5
var bulletspeed = 400
var direction = -1

func _ready():
	connect("body_entered", self, "_on_body_entered")
	$AnimatedSprite.flip_h = (direction == 1)
	pass # Replace with function body.

func _physics_process(delta):
	position.x += bulletspeed * direction * delta

func set_direction(_direction):
	direction = _direction

func _on_body_entered(body):
	if body.is_in_group("Player"):
		var knockback_velocity = knockback
		knockback_velocity.x *= direction
		body.knockback(knockback_velocity, stuntime)
	queue_free()
