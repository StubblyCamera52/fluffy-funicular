extends Node

signal took_damage(pos: Vector3)
signal xp_changed()
signal player_obtained_collectable()

var player_health := 100
var player_xp := 0
var player_level := 1
var player_collectables := 0
var player_powerups: Dictionary[String,GenericPowerUp] = {}
var player_model: CharacterBody3D
signal sacrifice(doorpos: Vector3)

var player_num_jumps: int = 1
var player_can_wall_jump: bool = false
var player_can_dash: bool = false

func set_player_var(player: CharacterBody3D):
	player_collectables = 0
	player_health = 100
	player_level = 2#5
	player_xp = 9#20
	give_player_xp(0)
	took_damage.emit()
	xp_changed.emit()
	player_obtained_collectable.emit()
	player_model = player

func damage_player(dmgAmount: int, pos: Vector3):
	player_health -= dmgAmount
	took_damage.emit(pos)
	if player_health <= 0:
		for key in player_powerups.keys():
			player_powerups[key].deactivate()
			player_powerups.erase(key)
		get_tree().reload_current_scene()

func give_player_xp(xpAmount: int):
	player_xp += xpAmount
	print(player_xp)
	player_level = floor(player_xp/5)+1
	print(player_level)
	xp_changed.emit()
	for key in player_powerups.keys():
			player_powerups.get(key).deactivate()
			player_powerups.erase(key)
	if player_level > 1:
		apply_powerup(DoubleJump.new())
	if player_level > 2:
		apply_powerup(WallJump.new())
	if player_level > 3:
		apply_powerup(AirDash.new())
	if player_level > 4:
		apply_powerup(TripleJump.new())
	print(player_can_wall_jump)

func apply_powerup(powerup: GenericPowerUp):
	if player_powerups.get(powerup.name) != null:
		return
	player_powerups.set(powerup.name, powerup)
	
	player_powerups[powerup.name].activate()
	
func remove_powerup(powerup: GenericPowerUp):
	if player_powerups.get(powerup.name) != null:
		player_powerups[powerup.name].deactivate()
		player_powerups.erase(powerup.name)

func sacrifice_animation(doorpos: Vector3):
	sacrifice.emit(doorpos)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#apply_powerup(TripleJump.new())
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for key in player_powerups:
		player_powerups[key].powerup_periodic()
