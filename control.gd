extends Control

func _init() -> void:
	PlayerGlobalManager.took_damage.connect(update_player_health_ui)

func update_player_health_ui() -> void:
	$Health.text = str(PlayerGlobalManager.player_health)
