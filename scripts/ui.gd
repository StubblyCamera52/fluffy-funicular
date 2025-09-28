extends Control

func _init() -> void:
	PlayerGlobalManager.took_damage.connect(update_player_health_ui)
	PlayerGlobalManager.xp_changed.connect(update_player_level_ui)
	PlayerGlobalManager.xp_changed.connect(update_xp_next_level_ui)
	PlayerGlobalManager.xp_changed.connect(update_ability_ui)

func update_player_health_ui() -> void:
	$MarginContainer/VBoxContainer/health.text = str("Health: "+str(PlayerGlobalManager.player_health))

func update_player_level_ui() -> void:
	$MarginContainer/VBoxContainer/level.text = str("Level: "+str(PlayerGlobalManager.player_level))

func update_xp_next_level_ui() -> void:
	$MarginContainer/VBoxContainer/xpToNextLevel.text = str("XP to next level: "+str(5-(PlayerGlobalManager.player_xp-((PlayerGlobalManager.player_level*5)-5))))

var previous_level := 1

func update_ability_ui() -> void:
	if PlayerGlobalManager.player_level > previous_level:
		match PlayerGlobalManager.player_level:
			2:
				$"Ability Unlock".text = '''[shake rate=20.0 level=5 connected=1][b]New Ability Unlocked:[/b][/shake]\n[color=green]Double Jump[/color]\nJump in the air to activate'''
				$"Ability Unlock/DisplayTimer".start()
			3:
				$"Ability Unlock".text = '''[shake rate=20.0 level=5 connected=1][b]New Ability Unlocked:[/b][/shake]\n[color=green]Wall Jump[/color]\nJump off a wall to activate'''
				$"Ability Unlock/DisplayTimer".start()
			4:
				$"Ability Unlock".text = '''[shake rate=20.0 level=5 connected=1][b]New Ability Unlocked:[/b][/shake]\n[color=green]Triple Jump[/color]\nJump in the air to activate'''
				$"Ability Unlock/DisplayTimer".start()
			5:
				$"Ability Unlock".text = '''[shake rate=20.0 level=5 connected=1][b]New Ability Unlocked:[/b][/shake]\n[color=green]Nothing[/color]\n In progess'''
				$"Ability Unlock/DisplayTimer".start()
			_:
				pass
	previous_level = PlayerGlobalManager.player_level


func _on_display_timer_timeout() -> void:
	$"Ability Unlock".text = ""
