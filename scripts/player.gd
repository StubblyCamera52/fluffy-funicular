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
@export var DASH_MULTIPLIER := 5

#player vars
var mouse_locked := true
var attack_time = 0
var sacrifice_timer = 0

# player state vars
enum PLAYER_STATES {
	BASIC,
	MOVEMENT_DISABLE,
	IN_MENU,
	ATTACKING,
	KNOCKBACK,
	SACRIFICE
}

var current_player_state: PLAYER_STATES = PLAYER_STATES.BASIC
var player_velocity := Vector3.ZERO
var player_direction := Vector3.ZERO
var player_input_direction := Vector2.ZERO
var times_jumped: int = 0
var dash_debounce := false

func _ready() -> void:
	if OS.has_feature("web"):
		#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		pass
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	PlayerGlobalManager.set_player_var(self)
	PlayerGlobalManager.sacrifice.connect(playSacrificeAnim)
	PlayerGlobalManager.took_damage.connect(knockback)

func knockback(pos: Vector3):
	current_player_state = PLAYER_STATES.KNOCKBACK
	player_velocity = Vector3(global_position-pos).normalized()*Vector3(1,0,1)*50+Vector3.UP*10

func playSacrificeAnim(doorpos: Vector3):
	current_player_state=PLAYER_STATES.SACRIFICE
	_playerModel.rotation.y = PI-global_position.angle_to(doorpos)
	_playerAnimator.play("Sacrifice",0.1,1)
	sacrifice_timer=5

func _input(event: InputEvent) -> void:
	if OS.has_feature("web"):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				get_tree().set_input_as_handled()
		if event.is_action_pressed("ui_cancel"):
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				get_tree().set_input_as_handled()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("unlock_mouse"):
		if !OS.has_feature("web"):
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
		current_player_state=PLAYER_STATES.ATTACKING
		_playerAnimator.playback_default_blend_time = 0.05
		_playerAnimator.play("Slash")
	if event.is_action_pressed("Special") and not dash_debounce and PlayerGlobalManager.player_can_dash and not is_on_floor() and not is_on_wall():
		dash_debounce = true
		player_velocity.x *= DASH_MULTIPLIER
		player_velocity.z *= DASH_MULTIPLIER
		if player_velocity.y < 0:
			player_velocity.y = 3
		
func _physics_process(delta: float) -> void:
	attack_time=move_toward(attack_time,0,delta)
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
			if attack_time < 0.25 and attack_time>0.025:
				for body in $PlayerModel/AttackCollider.get_overlapping_bodies():
					body.take_damage(10)
			if attack_time<=0:
				current_player_state=PLAYER_STATES.BASIC
			_playerAnimator.playback_default_blend_time = 0.25
		PLAYER_STATES.KNOCKBACK:
			_playerAnimator.play("Hurt")
		PLAYER_STATES.SACRIFICE:
			player_velocity.x = move_toward(player_velocity.x, 0,delta*15)
			player_velocity.z = move_toward(player_velocity.z, 0,delta*15)
			sacrifice_timer-=delta
			if sacrifice_timer <= 0:
				current_player_state = PLAYER_STATES.BASIC



	player_velocity.x *= DECELERATION
	player_velocity.z *= DECELERATION
	
	
	
	if not is_on_floor():
		player_velocity.y -=GRAVITY_FORCE*delta
	else:
		dash_debounce = false
		if player_velocity.y<0:
			times_jumped = 0
			player_velocity.y = 0
	
	velocity = player_velocity
	move_and_slide()
	if is_on_floor():
		if current_player_state == PLAYER_STATES.KNOCKBACK:
			current_player_state = PLAYER_STATES.BASIC


func _on_enemy_collision_area_body_entered(body: Node3D) -> void:
	if body.damage:
		print(body.identifier)
		if body.identifier == "bullet":
			body.queue_free()
		PlayerGlobalManager.damage_player(body.damage, body.global_position)
