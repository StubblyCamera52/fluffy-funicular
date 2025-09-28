extends Control

func _init() -> void:
	PlayerGlobalManager.took_damage.connect(update_player_health_ui)
	PlayerGlobalManager.xp_changed.connect(update_player_level_ui)
	PlayerGlobalManager.xp_changed.connect(update_xp_next_level_ui)
	PlayerGlobalManager.xp_changed.connect(update_ability_ui)
	PlayerGlobalManager.player_obtained_collectable.connect(update_collectable_ui)

func update_collectable_ui(subtitle: String):
	$MarginContainer/VBoxContainer/collectibles.text = str("Collectables: "+str(PlayerGlobalManager.player_collectables)+"/5")
	$"Ability Unlock".text = '''[shake rate=20.0 level=5 connected=1][b][color=yellow]YOU GOT A STARCORE![/color][/b][/shake]\n'''+'"'+subtitle+'"'
	$"Ability Unlock/DisplayTimer".start()

func update_player_health_ui(pos: Vector3) -> void:
	$MarginContainer/VBoxContainer/health.text = str("Health: "+str(PlayerGlobalManager.player_health)+str("/100"))

func update_player_level_ui() -> void:
	$MarginContainer/VBoxContainer/level.text = str("Level: "+str(PlayerGlobalManager.player_level))

func update_xp_next_level_ui() -> void:
	$MarginContainer/VBoxContainer/xpToNextLevel.text = str("XP to next level: "+str(5-(PlayerGlobalManager.player_xp-((PlayerGlobalManager.player_level*5)-5))))

var previous_level := 1

func update_ability_ui() -> void:
	if PlayerGlobalManager.player_level > previous_level:
		match PlayerGlobalManager.player_level:
			2:
				$"Ability Unlock".text = '''[shake rate=20.0 level=5 connected=1][b]New Ability Unlocked:[/b][/shake]\n[color=yellow]Double Jump[/color]\nJump in the air to activate'''
				$"Ability Unlock/DisplayTimer".start()
			3:
				$"Ability Unlock".text = '''[shake rate=20.0 level=5 connected=1][b]New Ability Unlocked:[/b][/shake]\n[color=yellow]Wall Jump[/color]\nJump midair next to a wall to activate'''
				$"Ability Unlock/DisplayTimer".start()
			4:
				$"Ability Unlock".text = '''[shake rate=20.0 level=5 connected=1][b]New Ability Unlocked:[/b][/shake]\n[color=yellow]Air Dash[/color]\n Press Shift in the air to activate'''
				$"Ability Unlock/DisplayTimer".start()
			5:
				$"Ability Unlock".text = '''[shake rate=20.0 level=5 connected=1][b]New Ability Unlocked:[/b][/shake]\n[color=yellow]Triple Jump[/color]\nJump in the air to activate'''
				$"Ability Unlock/DisplayTimer".start()
			_:
				pass
	previous_level = PlayerGlobalManager.player_level


func _on_display_timer_timeout() -> void:
	$"Ability Unlock".text = ""
