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
@export var JUMP_VELOCITY := 4.5

#player vars
var mouse_locked := true

# player state vars
enum PLAYER_STATES {
	BASIC,
	MOVEMENT_DISABLE,
	IN_MENU,
	ATTACKING,
}

var current_player_state: PLAYER_STATES = PLAYER_STATES.BASIC
var player_velocity := Vector3.ZERO
var player_direction := Vector3.ZERO
var player_input_direction := Vector2.ZERO

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

func _physics_process(delta: float) -> void:
	# State Machine
	match current_player_state:
		PLAYER_STATES.BASIC:
			if player_velocity.length()>0:
				_playerModel.rotation.y = PI/2-Vector2(player_velocity.x,player_velocity.z).angle()
				
			_playerAnimator.set_blend_time("Walk","Idle",0.25)
			if player_velocity.length() > 3:
				_playerAnimator.play("Walk",-1,player_velocity.length()/10)
				#_playerAnimator.speed_scale = 5
			else:
				_playerAnimator.play("Idle")
			
			player_input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward", 0.5)
			player_direction = (transform.basis * Vector3(player_input_direction.x, 0, player_input_direction.y)).normalized().rotated(Vector3.UP, %CameraPivot.rotation.y)
			if player_direction != Vector3.ZERO:
				player_velocity.x += player_direction.x * ACCELERATION
				player_velocity.z += player_direction.z * ACCELERATION



	player_velocity.x *= DECELERATION
	player_velocity.z *= DECELERATION
	
	
	velocity = player_velocity
	if not is_on_floor():
		velocity.y = -1
	else:
		velocity.y = 0
	move_and_slide()


func _on_enemy_collision_area_body_entered(body: Node3D) -> void:
	if body.damage:
		PlayerGlobalManager.damage_player(body.damage)
