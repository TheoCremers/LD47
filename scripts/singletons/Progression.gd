extends Node

var timescore : float = 0
var dash_unlocked : bool = false

# 0 = locked
# 1 = 30 sec cooldown
# 2 = 15 sec cooldown
# 3 = 5 sec cooldown
var transloc_level: int = 0

var cleared_bonus_rooms : Array

func clear_bonus_room(number: int):
	if !cleared_bonus_rooms.has(number):
		cleared_bonus_rooms.append(number)

func is_bonus_room_cleared(number: int):
	return cleared_bonus_rooms.has(number)

