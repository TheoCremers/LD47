extends Area2D

export(float) var damage_amount = 10

func _ready():
	$AnimatedSprite.playing = true

func _on_AnimatedSprite_animation_finished():
	call_deferred('free')
