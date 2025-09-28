class_name AirDash extends GenericPowerUp

func _init() -> void:
	name = "AirDash"

func activate() -> void:
	PlayerGlobalManager.player_can_dash = true

func deactivate() -> void:
	PlayerGlobalManager.player_can_dash = false
