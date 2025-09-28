class_name DoubleJump extends GenericPowerUp

func _init() -> void:
	name = "DoubleJump"

func activate() -> void:
	PlayerGlobalManager.player_num_jumps = 2

func deactivate() -> void:
	PlayerGlobalManager.player_num_jumps = 1
