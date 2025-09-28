extends Enemy

var target_player = null
var firing = false
var target_rotation = 0
@export var ROTATE_SPEED := 5
@export var BULLET_SPEED = 10
@onready var bullet_scene = load("res://assets/objects/bullet.tscn")

func _ready() -> void:
	actor_setup.call_deferred()
	max_health = 5
	health = max_health
	original_pos = global_position
	
func actor_setup():
	shoot_bullet(Vector3.ZERO)

func set_movement_target(movement_target: Vector3):
	pass

	
func _physics_process(delta: float) -> void:
	velocity = Vector3.ZERO
	
	if target_player != null:
		var player_pos: Vector3 = target_player.global_position+target_player.velocity/3
		var direction: float = PI/2-Vector2(global_position.direction_to(player_pos).x,global_position.direction_to(player_pos).z).angle()
		rotation.y = lerp_angle(rotation.y, direction, ROTATE_SPEED*delta)
		
	
	if !is_on_floor():
		velocity = Vector3(0, -50, 0)
	
	move_and_slide()


func shoot_bullet(target_pos: Vector3):
	var bullet: RigidBody3D = bullet_scene.instantiate()
	get_parent_node_3d().add_child(bullet)
	bullet.position = global_position + Vector3(0,1.3,0)
	bullet.rotation.y = rotation.y
	bullet.apply_central_impulse((target_pos-global_position).normalized()*BULLET_SPEED)
	

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		target_player = body


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body == target_player:
		target_player = null


func _on_shoot_timer_timeout() -> void:
	firing = !firing

func _on_rapid_fire_timer_timeout() -> void:
	if target_player != null and firing:
		shoot_bullet(target_player.global_position+target_player.velocity/3)
