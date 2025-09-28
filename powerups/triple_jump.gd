class_name TripleJump extends GenericPowerUp

func _init() -> void:
	name = "TripleJump"

func activate() -> void:
	PlayerGlobalManager.player_num_jumps = 3

func deactivate() -> void:
	PlayerGlobalManager.player_num_jumps = 1
