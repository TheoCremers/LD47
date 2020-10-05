extends Area2D

export(float) var damage_amount = 10

func _ready():
	$AnimatedSprite.playing = true
	connect("body_entered", self, "_on_body_entered")

func _on_AnimatedSprite_animation_finished():
	call_deferred('free')

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		body.on_hit()
	pass
