extends Area2D

export (String) var NextRoomName
export (String) var WarpRoomName
export (int) var TimescoreRequirement = 0
export (int) var BonusRoomId = 0

# Gebruik van de ExitPortal:
# NextRoomName = naam van de scene binnen de scene/rooms map waarnaar de deur leidt
# WarpRoomName = Alleen van toepassing als de deur naar een powerup room leidt. 
# In dit geval wil je ook aangeven welke exit de powerup room heeft. Dit zodat iedere
# powerup room maar één keer bezocht kan worden. Bij een tweede entry dient het dus
# als een soort van warp portal.
# TimescoreRequirement = Bij meer dan 0 is het een deur met een time requirement.
# BonusRoomId = Uniek Id van de gelinkte bonus room, indien relevant. Zet dit ook
# in de export var van de bonus room.

func _ready():
	connect("body_entered", self, "_on_player_entered")
	if (TimescoreRequirement > 0):
		$Panel.visible = true
		$Panel/TimescoreIcon/Label.text = str(TimescoreRequirement)
	if (BonusRoomId == 0):
		$Sprite.play("green_locked")
	elif (TimescoreRequirement > Progression.timescore):
		$Sprite.play("red_locked")
	else:
		$Sprite.play("green_locked")
	pass

func _on_player_entered(_body):
	if $Sprite.animation == "open":
		if BonusRoomId != 0 and Progression.is_bonus_room_cleared(BonusRoomId):
			# Powerup room cleared. Door is now a warp to the connected room.
			get_tree().call_group("game", "room_transition", WarpRoomName, position)
			return
		get_tree().call_group("game", "room_transition", NextRoomName, position)
		return

func _physics_process(_delta):
	var enemies_alive = get_tree().get_nodes_in_group("enemies").size()
	var powerups = get_tree().get_nodes_in_group("powerups").size()
	if (enemies_alive == 0 && powerups == 0):
		if $Sprite.animation == "green_locked":
			$Sprite.play("open")
