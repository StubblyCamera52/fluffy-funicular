extends Enemy

var target_pos: Vector3 = Vector3.ZERO
var charging := false
var direction := Vector2.ZERO

func _ready() -> void:
	actor_setup.call_deferred()
	damage = 20
	movement_speed = 20
	max_health = 100
	health = max_health
	original_pos = global_position

func set_movement_target(movement_target: Vector3):
	pass
	
func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity = Vector3(0, -10, 0)
		
	if charging:
		velocity = Vector3(direction.x*movement_speed,velocity.y,direction.y*movement_speed)
	else:
		velocity.x = 0
		velocity.z = 0
	
	move_and_slide()


func _on_chargeup_timeout() -> void:
	charging = true
	$Charge.start()
	direction = Vector2((target_pos-global_position).normalized().x,(target_pos-global_position).normalized().z)

func _on_area_3d_body_entered(body: Node3D) -> void:
	target_pos = body.global_position
	$Chargeup.start()


func _on_charge_timeout() -> void:
	charging = false
