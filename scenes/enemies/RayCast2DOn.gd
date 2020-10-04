extends RayCast2D


var is_casting = false setget set_is_casting

# Called when the node enters the scene tree for the first time.
func _ready():
	self.is_casting = true
	set_physics_process(true)
	$Line2D.points[1] = Vector2.ZERO

func _physics_process(_delta):
	var cast_point := cast_to
	force_raycast_update()
	
	if is_colliding():
		cast_point = to_local(get_collision_point())
		var collide = get_collider()
		if(collide.is_in_group("Player")):
			collide._on_death()
		
	$Line2D.points[1] = cast_point

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
