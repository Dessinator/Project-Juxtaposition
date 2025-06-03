@tool
extends FSMState

const AGILITY: StringName = &"agility"
const MOVEMENT_SPEED: StringName = &"movement_speed"

#const WALL_PULL_FORCE: int = 1
#const GRAVITY: float = 2
#const ACCELERATION: int = 40
#const VERTICAL_STAMINA_MAX: float = 5.0
#const VERTICAL_SPEED: float = 6.5
#const HORIZONTAL_SPEED_MAX: float = 2.2
#const HORIZONTAL_SPEED_MIN: float = 1.5

@export var _wall_pull_force: int = 1
@export var _gravity: float = 2.0
@export var _acceleration: float = 40
@export var _speed_multiplier: float
@export var _horizontal_speed_min: float = 1.5
@export var _horizontal_speed_max: float = 2.2

@export var _camera: PlayableCharacterCamera
@export var _character: Character
@export var _animation_state: FSMState

@onready var _animation_finite_state_machine: FiniteStateMachine = %AnimationFiniteStateMachine

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	var status = actor.get_status()
	
	_animation_finite_state_machine.change_state(_animation_state)
	
	var last_slide_collision = actor.get_last_slide_collision()
	if not last_slide_collision:
		get_parent().fire_event("on_start_falling")
		return
	blackboard.set_value("current_wall_normal", last_slide_collision.get_normal())

# Executes every _process call, if the state is active.
func _on_update(delta: float, actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	
	var last_slide_collision = actor.get_last_slide_collision()
	blackboard.set_value("current_wall_normal", last_slide_collision.get_normal())
	
	var wall_negative_normal = -blackboard.get_value("current_wall_normal")
	var gravity = -_gravity
	
	var horizontal_camera_rotation = _camera.get_horizontal_rotation()
	var direction = _handle_direction_input(horizontal_camera_rotation)
	
	var stats = _character.get_character_stats()
	var agility_stat = stats.get_stat(AGILITY)
	var agility_value = agility_stat.get_value(false)
	var movement_speed_stat = stats.get_substat(MOVEMENT_SPEED)
	var movement_speed_value = movement_speed_stat.sample(agility_value, false)
	var speed = movement_speed_value * _speed_multiplier
	
	var velocity = _handle_wallsliding(
		actor,
		wall_negative_normal,
		actor.velocity,
		direction,
		speed,
		gravity,
		delta)
	
	actor.velocity = velocity
	
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	if not horizontal_velocity.is_zero_approx():
		var horizontal_velocity_normalized = horizontal_velocity.normalized()
		_character.rotation.y = atan2(horizontal_velocity_normalized.x, horizontal_velocity_normalized.z)

# Executes before the state is exited.
func _on_exit(actor: Node, _blackboard: BTBlackboard) -> void:
	pass

func _handle_direction_input(horizontal_rotation: float) -> Vector3:
	var input_direction = Input.get_vector("strafe_left", "strafe_right", "forwards", "backwards")
	var direction = Vector3(input_direction.x, 0, input_direction.y)
	direction = direction.rotated(Vector3.UP, horizontal_rotation).normalized()
	
	return direction

func _handle_wallsliding(playable_character: PlayableCharacter, wall_negative_normal: Vector3, current_velocity: Vector3, direction: Vector3, speed: float, gravity: float, delta) -> Vector3:
	var wall_pull = wall_negative_normal * _wall_pull_force
	var dot = wall_negative_normal.dot(direction)
	var horizontal_speed = remap(dot, 0, 1, _horizontal_speed_max, _horizontal_speed_min) * speed
	dot = remap(dot, -1, 1, -1, 0)
	var vertical_speed = gravity + dot * speed
		
	var target_velocity = Vector3(
		float(direction.x * horizontal_speed),
		vertical_speed,
		float(direction.z * horizontal_speed))
	var velocity = current_velocity.move_toward(target_velocity, _acceleration * delta) + wall_pull
	
	return velocity
