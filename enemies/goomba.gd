extends Enemy

@onready var _animator: AnimationPlayer = $GoombaModel/AnimationPlayer

var target_player = null

func _ready() -> void:
	identifier = "enemy"
	damage = 5
	actor_setup.call_deferred()
	
func actor_setup():
	await get_tree().physics_frame

	
func _physics_process(delta: float) -> void:
	print(velocity)
	_animator.set_blend_time("Walk","Idle",0.25)
	_animator.set_blend_time("Walk","Idle",0.25)
	if velocity.length()>5:
		_animator.play("Walk",-1,velocity.length()/4.5)
		rotation.y = PI/2-Vector2(velocity.x,velocity.z).angle()
	else:
		_animator.play("Idle")
	if target_player != null:
		set_movement_target(target_player.global_position)
	velocity = Vector3.ZERO
	
	if nav_agent.is_navigation_finished():
		if !is_on_floor():
			velocity.y -= 1
		else:
			velocity.y = 0
		move_and_slide()
		return
	var next_location := nav_agent.get_next_path_position()
	velocity = global_position.direction_to(next_location)*movement_speed
	if !is_on_floor():
		velocity.y -= 1
	else:
		velocity.y = 0
	move_and_slide()

func _on_targeting_area_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		target_player = body


func _on_targeting_area_body_exited(body: Node3D) -> void:
	if body == target_player:
		target_player = null
