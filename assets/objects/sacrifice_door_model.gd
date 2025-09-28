extends Node3D
@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var collision = $StaticBody3D/CollisionShape3D
var opened = false

func _on_area_3d_body_entered(body: Node3D) -> void:
	if not opened and PlayerGlobalManager.player_level>=2:
		PlayerGlobalManager.player_xp=PlayerGlobalManager.player_level*5-10
		PlayerGlobalManager.give_player_xp(0)
		PlayerGlobalManager.sacrifice_animation(global_position)
		opened=true
		await get_tree().create_timer(4.5).timeout
		animator.play("Open")
		await get_tree().create_timer(0.25).timeout
		collision.queue_free()
