extends Node3D
@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var particle = self.get_node_or_null("CollectParticle")
@onready var model = $Armature

func _ready() -> void:
	animator.play("Spin")

func _on_area_3d_body_entered(body: Node3D) -> void:
	model.queue_free()
	particle.restart()
	await get_tree().create_timer(1).timeout
	queue_free()
