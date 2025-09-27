extends RigidBody3D

@export var damage := 1
@export var identifier := "bullet"


func _on_timer_timeout() -> void:
	queue_free()
