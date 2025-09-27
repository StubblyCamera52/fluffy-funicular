extends Node

var player_health := 100
var player_xp := 0
var player_level := 1
var player_powerups := []

func damage_player(dmgAmount: int):
	player_health -= dmgAmount

func give_player_xp(xpAmount: int):
	player_xp += xpAmount

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
