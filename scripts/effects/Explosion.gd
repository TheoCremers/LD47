extends Area2D

export(float) var damage_amount = 10

func _ready():
	$AnimatedSprite.playing = true
	connect("area_entered", self, "_on_area_entered")

func _on_AnimatedSprite_animation_finished():
	call_deferred('free')

func _on_area_entered(area):
	if area.is_in_group("enemies"):
		area.on_hit()
	pass
