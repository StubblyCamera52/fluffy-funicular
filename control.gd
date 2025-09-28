extends Control

func _init() -> void:
	PlayerGlobalManager.took_damage.connect(update_player_health_ui)
	PlayerGlobalManager.level_changed.connect(update_player_level_ui)

func update_player_health_ui() -> void:
	$Health.text = str("Health: "+str(PlayerGlobalManager.player_health))

func update_player_level_ui() -> void:
	$Level.text = str("Level: "+str(PlayerGlobalManager.player_level))
