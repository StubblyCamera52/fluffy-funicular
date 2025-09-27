extends CharacterBody3D

# Node imports
@onready var _camera := %Camera3D as Camera3D
@onready var _camera_pivot := %CameraPivot as Node3D

@export_range(0.01, 1) var mouse_sens := 0.01
@export var cam_tilt_limit := deg_to_rad(75)

#player vars
var mouse_locked := true

# player state vars
enum PLAYER_STATES {
	IDLE,
	IN_MENU,
	WALKING,
	JUMPING,
}
var current_player_state: PLAYER_STATES = PLAYER_STATES.WALKING
var player_velocity := Vector3.ZERO
var player_direction := Vector3.ZERO
var player_input_direction := Vector2.ZERO

# Player Movement Config
@export var MAX_SPEED := 20.0
@export var ACCELERATION := 2.0
@export var DECELERATION := 0.9
@export var JUMP_VELOCITY := 4.5

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

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
	# Add the gravity.
		
	match current_player_state:
		PLAYER_STATES.WALKING:
			player_input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward", 0.5)
			player_direction = (transform.basis * Vector3(player_input_direction.x, 0, player_input_direction.y)).normalized().rotated(Vector3.UP, %CameraPivot.rotation.y)


	if player_direction != Vector3.ZERO:
		player_velocity.x += player_direction.x * ACCELERATION
		player_velocity.z += player_direction.z * ACCELERATION
		player_velocity.x *= DECELERATION
		player_velocity.z *= DECELERATION
	else:
		player_velocity.x *= DECELERATION
		player_velocity.z *= DECELERATION
		
	
	velocity = player_velocity
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()
