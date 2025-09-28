extends CharacterBody3D

# Node imports
@onready var _camera := %Camera3D as Camera3D
@onready var _camera_pivot := %CameraPivot as Node3D
@onready var _playerAnimator: AnimationPlayer = $PlayerModel/AnimationPlayer
@onready var _playerModel: Node3D = $PlayerModel

@export_range(0, 1) var mouse_sens := 0.01
@export var cam_tilt_limit := deg_to_rad(75)

# Player Movement Config
@export var MAX_SPEED := 20.0
@export var ACCELERATION := 2.0
@export var DECELERATION := 0.9
@export var GRAVITY_FORCE := 20.0
@export var JUMP_VELOCITY := 4.5

#player vars
var mouse_locked := true
var attack_time = 0

# player state vars
enum PLAYER_STATES {
	BASIC,
	MOVEMENT_DISABLE,
	IN_MENU,
	ATTACKING,
	KNOCKBACK
}

var current_player_state: PLAYER_STATES = PLAYER_STATES.BASIC
var player_velocity := Vector3.ZERO
var player_direction := Vector3.ZERO
var player_input_direction := Vector2.ZERO
var times_jumped: int = 0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	PlayerGlobalManager.set_player_var(self)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("unlock_mouse"):
		mouse_locked = !mouse_locked
		match mouse_locked:
			true:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			false:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and mouse_locked:
		_camera_pivot.rotation.x -= event.relative.y * mouse_sens
		_camera_pivot.rotation.x = clampf(_camera_pivot.rotation.x, -cam_tilt_limit, cam_tilt_limit)
		_camera_pivot.rotation.y -= event.relative.x * mouse_sens
	if event.is_action_pressed("Jump"):
		if is_on_floor() or times_jumped < PlayerGlobalManager.player_num_jumps:
			times_jumped += 1
			player_velocity.y=JUMP_VELOCITY
		if is_on_wall_only() and PlayerGlobalManager.player_can_wall_jump:
			if Vector2(get_wall_normal().x,get_wall_normal().z).length() > 0.9:
				player_velocity = (60*Vector3(get_wall_normal().x,0,get_wall_normal().z))+Vector3(0,JUMP_VELOCITY,0)
	if event.is_action_pressed("Attack") and attack_time==0:
		attack_time=0.35
		_playerAnimator.playback_default_blend_time = 0.05
		_playerAnimator.play("Slash")

func _physics_process(delta: float) -> void:
	if attack_time>0:
		current_player_state=PLAYER_STATES.ATTACKING
		attack_time=move_toward(attack_time,0,delta)
	else:
		current_player_state=PLAYER_STATES.BASIC
	
	
	# State Machine
	match current_player_state:
		PLAYER_STATES.BASIC:
			_playerAnimator.set_blend_time("Walk","Fall",0.1)
			_playerAnimator.set_blend_time("Idle","Fall",0.1)
			if player_velocity.length()>0:
					_playerModel.rotation.y = PI/2-Vector2(player_velocity.x,player_velocity.z).angle()
			if is_on_floor():
				_playerAnimator.playback_default_blend_time = 0.1
				_playerAnimator.set_blend_time("Walk","Idle",0.25)
				if player_velocity.length() > 3:
					_playerAnimator.play("Walk",-1,player_velocity.length()/10)
				else:
					_playerAnimator.play("Idle")
			else:
				if player_velocity.y > 0:
					_playerAnimator.play("Jump")
				else:
					_playerAnimator.play("Fall")
				_playerAnimator.playback_default_blend_time = 0.25
			
			player_input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward", 0.5)
			player_direction = (transform.basis * Vector3(player_input_direction.x, 0, player_input_direction.y)).normalized().rotated(Vector3.UP, %CameraPivot.rotation.y)
			if player_direction != Vector3.ZERO:
				player_velocity.x += player_direction.x * ACCELERATION
				player_velocity.z += player_direction.z * ACCELERATION
		PLAYER_STATES.ATTACKING:
			if attack_time < 0.2 and attack_time>0.05:
				for body in $PlayerModel/AttackCollider.get_overlapping_bodies():
					body.take_damage(10)
			_playerAnimator.playback_default_blend_time = 0.25
		PLAYER_STATES.KNOCKBACK:
			pass



	player_velocity.x *= DECELERATION
	player_velocity.z *= DECELERATION
	
	
	
	if not is_on_floor():
		player_velocity.y -=GRAVITY_FORCE*delta
	else:
		if player_velocity.y<0:
			times_jumped = 0
			player_velocity.y = 0
	
	velocity = player_velocity
	move_and_slide()


func _on_enemy_collision_area_body_entered(body: Node3D) -> void:
	if body.damage:
		print(body.identifier)
		if body.identifier == "bullet":
			body.queue_free()
		PlayerGlobalManager.damage_player(body.damage)
