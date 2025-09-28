extends Enemy

@onready var _animator: AnimationPlayer = $GoombaModel/AnimationPlayer

var is_being_knocked_back := false
var knock_back := false
var target_player = null

func _ready() -> void:
	original_pos = global_position
	identifier = "enemy"
	damage = 5
	actor_setup.call_deferred()
	max_health = 15
	health = max_health
	
func actor_setup():
	await get_tree().physics_frame

func take_damage(dmg_amount: int) -> void:
	if dmg_debounce > 0:
		return
	dmg_debounce = 0.355
	health -= dmg_amount
	knock_back = true
	if health <= 0:
		die()
	else:
		if damage_particle:
			damage_particle.restart()

func _physics_process(delta: float) -> void:
	#print(dmg_debounce)
	#print(velocity)
	_animator.set_blend_time("Walk","Idle",0.25)
	_animator.set_blend_time("Walk","Idle",0.25)
	_animator.set_blend_time("Walk","Hurt",0.25)
	_animator.set_blend_time("Hurt","Walk",0.25)
	_animator.set_blend_time("Hurt","Idle",0.25)
	if velocity.length()>1:
		if is_being_knocked_back:
			_animator.play("Hurt",-1,2)
		else:
			_animator.play("Walk",-1,velocity.length()/4.5)
		rotation.y = PI/2-Vector2(velocity.x,velocity.z).angle()
		if is_being_knocked_back:
			rotation.y+=PI
	else:
		_animator.play("Idle")
	if target_player != null:
		set_movement_target(target_player.global_position)
	
	if !is_being_knocked_back:
		velocity = Vector3.ZERO
		
		if nav_agent.is_navigation_finished():
			if !is_on_floor():
				velocity.y -= 20*delta
			else:
				velocity.y = 0
			move_and_slide()
			return
		var next_location := nav_agent.get_next_path_position()
		velocity = global_position.direction_to(next_location)*movement_speed
	
	if !is_on_floor():
		velocity.y += -20*delta
	else:
		is_being_knocked_back = false
		velocity.y = 0
	
	if knock_back:
		print("knock")
		knock_back = false
		is_being_knocked_back = true
		if target_player:
			velocity = Vector3(global_position-target_player.global_position).normalized()*7+Vector3.UP*3
			print(velocity)
	
	move_and_slide()

func _on_targeting_area_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		target_player = body


func _on_targeting_area_body_exited(body: Node3D) -> void:
	if body == target_player:
		target_player = null
