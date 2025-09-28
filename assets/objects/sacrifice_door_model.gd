extends Node3D
@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var collision = $StaticBody3D/CollisionShape3D
var opened = false

func _on_area_3d_body_entered(body: Node3D) -> void:
	if not opened:
		animator.play("Open")
		opened=true
		await get_tree().create_timer(0.25).timeout
		collision.queue_free()
