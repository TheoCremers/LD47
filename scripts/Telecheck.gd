extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func check_up(length):
	$RayCastUp.cast_to.y = -length
	$RayCastUp.force_raycast_update()
	var collider = $RayCastUp.get_collider()
	if collider != null and collider.name == "TileMap":
		var tile_id = collider.get_cellv(collider.world_to_map\
		($RayCastUp.get_collision_point()))
		if (tile_id != -1):
			return collider.tile_set.tile_get_shape_one_way(tile_id, 0)
	return true
	
func check_down(length):
	$RayCastDown.cast_to.y = length
	$RayCastDown.force_raycast_update()
	var collider = $RayCastDown.get_collider()
	if collider != null and collider.name == "TileMap":
		var tile_id = collider.get_cellv(collider.world_to_map\
		($RayCastDown.get_collision_point()))
		if (tile_id != -1):
			return collider.tile_set.tile_get_shape_one_way(tile_id, 0)
	return true
