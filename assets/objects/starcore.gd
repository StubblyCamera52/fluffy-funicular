extends Node3D
@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var particle = self.get_node_or_null("CollectParticle")
@onready var model = $Armature
@export var collectibleName: String = ""
@onready var sfx = $AudioStreamPlayer3D

func _ready() -> void:
	particle.restart()
	animator.play("Spin")

func _on_area_3d_body_entered(body: Node3D) -> void:
	sfx.play()
	model.queue_free()
	$Area3D.queue_free()
	PlayerGlobalManager.player_collectables += 1
	PlayerGlobalManager.player_obtained_collectable.emit(collectibleName)
	particle.restart()
	await get_tree().create_timer(1).timeout
	queue_free()
