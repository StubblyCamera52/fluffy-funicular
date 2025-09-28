extends Control

func _init() -> void:
	PlayerGlobalManager.took_damage.connect(update_player_health_ui)
	PlayerGlobalManager.xp_changed.connect(update_player_level_ui)
	PlayerGlobalManager.xp_changed.connect(update_xp_next_level_ui)

func update_player_health_ui() -> void:
	$VBoxContainer/health.text = str("Health: "+str(PlayerGlobalManager.player_health))

func update_player_level_ui() -> void:
	$VBoxContainer/level.text = str("Level: "+str(PlayerGlobalManager.player_level))

func update_xp_next_level_ui() -> void:
	$VBoxContainer/xpToNextLevel.text = str("XP to next level: "+str(5-(PlayerGlobalManager.player_xp-((PlayerGlobalManager.player_level*5)-5))))
