extends RayCast2D

var is_casting = false setget set_is_casting

# Called when the node enters the scene tree for the first time.
func _ready():
	self.is_casting = true
	set_physics_process(true)
	$Line2D.points[1] = Vector2.ZERO
#	var mat =$BeamParticle2D.process_material.duplicate()
#	$BeamParticle2D.process_material = mat
#	$BeamParticle2D.emitting = true

func _physics_process(_delta):
	var cast_point := cast_to
	force_raycast_update()
	
	$CollisionParticle2D.emitting = is_colliding()
	
	if is_colliding():
		cast_point = to_local(get_collision_point())
		$CollisionParticle2D.global_rotation = get_collision_normal().angle()
		$CollisionParticle2D.position = cast_point
		var collide = get_collider()
		if(collide.is_in_group("Player")):
			collide._on_death()
		
	$Line2D.points[1] = cast_point
	
#	$BeamParticle2D.position = cast_point * 0.5
#	$BeamParticle2D.process_material.emission_box_extents.x = cast_point.length() * 0.5
	#$BeamParticle2D.amount = 100 * cast_point.length() / 300

func set_is_casting(cast : bool):
	is_casting = cast
		
	if is_casting:
		AudioManager.play_sfx("LaserPowerUp")
		appear()
	else:
		AudioManager.play_sfx("LaserPowerDown")
		disappear()
	
	set_physics_process(is_casting)

func appear():
	$Tween.stop_all()
	$Tween.interpolate_property($Line2D, "width", 0, 3.0, 0.2)
	$Tween.start()
	
func disappear():
	$Tween.stop_all()
	$Tween.interpolate_property($Line2D, "width", 3.0, 0, 0.1)
	$Tween.start()
