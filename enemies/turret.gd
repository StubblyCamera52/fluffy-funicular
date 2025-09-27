extends Enemy

func take_damage(dmg_amount: int) -> void:
	health -= dmg_amount
	if health <= 0:
		die()

func die() -> void:
	queue_free()

func _ready() -> void:
	actor_setup.call_deferred()
	
func actor_setup():
	pass

func set_movement_target(movement_target: Vector3):
	pass

	
func _physics_process(delta: float) -> void:
	velocity = Vector3.ZERO
	
	if !is_on_floor():
		velocity = Vector3(0, -1, 0)
	
	move_and_slide()
