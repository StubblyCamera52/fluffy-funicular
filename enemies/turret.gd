extends Enemy

var target_player = null
var target_rotation = 0
@export_range(0,5) var ROTATE_SPEED := 5

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
	
	if target_player != null:
		var player_pos: Vector3 = target_player.global_position
		var direction: float = PI/2-Vector2(global_position.direction_to(player_pos).x,global_position.direction_to(player_pos).z).angle()
		rotation.y = lerp_angle(rotation.y, direction, ROTATE_SPEED*delta)
		
	
	if !is_on_floor():
		velocity = Vector3(0, -1, 0)
	
	move_and_slide()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		target_player = body


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body == target_player:
		target_player = null
