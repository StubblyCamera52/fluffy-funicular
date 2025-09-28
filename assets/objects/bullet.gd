extends RigidBody3D

@export var damage := 1
@export var identifier := "bullet"



func _on_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node) -> void:
	queue_free()
