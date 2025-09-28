extends Enemy

@onready var _animator = $charger/AnimationPlayer
var target_pos: Vector3 = Vector3.ZERO
var charging := false
var direction := Vector2.ZERO
var knock_back := false
var target_player = null
var is_being_knocked_back := false

func _ready() -> void:
	_animator.play("Idle")
	actor_setup.call_deferred()
	damage = 20
	movement_speed = 20
	max_health = 100
	health = max_health
	original_pos = global_position
	
func take_damage(dmg_amount: int) -> void:
	if dmg_debounce > 0:
		return
	dmg_debounce = 0.355
	health -= dmg_amount
	knock_back = true
	if health <= 0:
		die()

func set_movement_target(movement_target: Vector3):
	pass
	
func _physics_process(delta: float) -> void:
	if is_being_knocked_back:
		charging = false
	if charging:
		velocity = Vector3(direction.x*movement_speed,velocity.y,direction.y*movement_speed)
	elif !is_being_knocked_back:
		velocity.x = 0
		velocity.z = 0
		
	if !is_on_floor():
		velocity.y += -20*delta
	else:
		if is_being_knocked_back:
			$charger/AnimationPlayer.play("Hurt")
			is_being_knocked_back = false
		velocity.y = 0
	
	if knock_back:
		charging = false
		print("knock")
		$charger/AnimationPlayer.play("Hurt")
		knock_back = false
		is_being_knocked_back = true
		if target_player:
			velocity = Vector3(global_position-target_player.global_position).normalized()*7+Vector3.UP*7
			print(velocity)
	
	move_and_slide()


func _on_chargeup_timeout() -> void:
	charging = true
	$charger/AnimationPlayer.play("Charge")
	$Charge.start()

func _on_area_3d_body_entered(body: Node3D) -> void:
	target_player = body
	if not charging:
		target_pos = body.global_position
		direction = Vector2((target_pos-global_position).normalized().x,(target_pos-global_position).normalized().z)
		rotation.y = PI/2-direction.angle()
		$charger/AnimationPlayer.play("Telegraph")
		$Chargeup.start()


func _on_charge_timeout() -> void:
	$charger/AnimationPlayer.play("Idle")
	charging = false
	if $Area3D.get_overlapping_bodies():
		_on_area_3d_body_entered($Area3D.get_overlapping_bodies()[0])
