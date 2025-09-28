class_name WallJump extends GenericPowerUp

func _init() -> void:
	name = "WallJump"

func activate() -> void:
	PlayerGlobalManager.player_can_wall_jump = true

func deactivate() -> void:
	PlayerGlobalManager.player_can_wall_jump = false
