class_name Enemy
extends CharacterBody3D

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var death_particle = self.get_node_or_null("DeathParticle")
@onready var damage_particle = self.get_node_or_null("DamageParticle")

# enemy config
@export var movement_speed: float = 5.0
@export var max_health: int = 100
@export var damage: int = 0
@export var identifier := "enemy"

@onready var sfx = $AudioStreamPlayer3D
var damagesfx = load("res://sounds/enemyhit.wav")
var destroysfx = load("res://sounds/enemy destroy.wav")

var health: int = max_health

var original_pos: Vector3 = Vector3(0, 1, 0)

var dmg_debounce := 0.0

func take_damage(dmg_amount: int) -> void:
	if dmg_debounce > 0:
		return
	dmg_debounce = 0.355
	health -= dmg_amount
	if health <= 0:
		die()
	else:
		if damage_particle:
			damage_particle.restart()

func die() -> void:
	sfx.stream = destroysfx
	sfx.play()
	PlayerGlobalManager.give_player_xp(1)
	if death_particle:
		death_particle.restart()
	health = max_health
	global_position.y -= 100
	await get_tree().create_timer(45).timeout
	global_position = original_pos

func _ready() -> void:
	actor_setup.call_deferred()
	
func actor_setup():
	await get_tree().physics_frame
	
	set_movement_target(Vector3(0,0.5,0))

func set_movement_target(movement_target: Vector3):
	nav_agent.set_target_position(movement_target)

func _process(delta: float) -> void:
	dmg_debounce = move_toward(dmg_debounce, 0.0, delta)

func _physics_process(delta: float) -> void:
	if nav_agent.is_navigation_finished():
		return
	
	var next_location := nav_agent.get_next_path_position()
	velocity = global_position.direction_to(next_location)*movement_speed
	
	if !is_on_floor():
		velocity = Vector3(0, -1, 0)
	
	move_and_slide()
