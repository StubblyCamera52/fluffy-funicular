extends Node

var player_health := 100
var player_xp := 0
var player_level := 1
var player_powerups: Dictionary[String,GenericPowerUp] = {}
var player_model: CharacterBody3D

func set_player_var(player: CharacterBody3D):
	player_model = player

func damage_player(dmgAmount: int):
	player_health -= dmgAmount

func give_player_xp(xpAmount: int):
	player_xp += xpAmount

func apply_powerup(powerup: GenericPowerUp):
	if player_powerups.get(powerup.name) != null:
		return
	player_powerups.set(powerup.name, powerup)
	
	player_powerups[powerup.name].activate()
	
func remove_powerup(powerup: GenericPowerUp):
	if player_powerups.get(powerup.name) != null:
		player_powerups[powerup.name].deactivate()
		player_powerups.erase(powerup.name)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#apply_powerup(GenericPowerUp.new())
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for key in player_powerups:
		player_powerups[key].powerup_periodic()
