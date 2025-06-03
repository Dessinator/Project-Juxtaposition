@tool
extends FSMState

const AGILITY: StringName = &"agility"
const MOVEMENT_SPEED: StringName = &"movement_speed"

#const WALL_PUSH_FORCE: float = 14
#const FORCE: float = 12.5
#const GRAVITY: float = 9.8
#const ACCELERATION: int = 40

@export var _wall_push_force: float = 14
@export var _force: float = 12.5
@export var _gravity: float = 9.8
@export var _acceleration: int = 40
@export var _speed_multiplier: float = 0.8

@export var _camera: PlayableCharacterCamera
@export var _character: Character
@export var _animation_state: FSMState

@onready var _animation_finite_state_machine: FiniteStateMachine = %AnimationFiniteStateMachine

func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	
	_animation_finite_state_machine.change_state(_animation_state)
	
	var velocity = _handle_wall_jump_force(actor.velocity, blackboard.get_value("current_wall_normal"))
	actor.velocity = velocity

func _on_update(delta: float, actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	
	var horizontal_camera_rotation = _camera.get_horizontal_rotation()
	var direction = _handle_direction_input(horizontal_camera_rotation)
	
	var stats = _character.get_character_stats()
	var agility_stat = stats.get_stat(AGILITY)
	var agility_value = agility_stat.get_value(false)
	var movement_speed_stat = stats.get_substat(MOVEMENT_SPEED)
	var movement_speed_value = movement_speed_stat.sample(agility_value, false)
	
	var velocity = _handle_wall_jump(
		actor.velocity,
		direction,
		movement_speed_value * _speed_multiplier,
		delta)
	
	if velocity.y < 0:
		get_parent().fire_event("on_start_falling")
		return

	actor.velocity = velocity
	
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	if not horizontal_velocity.is_zero_approx():
		var horizontal_velocity_normalized = horizontal_velocity.normalized()
		_character.rotation.y = atan2(horizontal_velocity_normalized.x, horizontal_velocity_normalized.z)

# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: BTBlackboard) -> void:
	pass

func _handle_direction_input(horizontal_rotation: float) -> Vector3:
	var input_direction = Input.get_vector("strafe_left", "strafe_right", "forwards", "backwards")
	var direction = Vector3(input_direction.x, 0, input_direction.y)
	direction = direction.rotated(Vector3.UP, horizontal_rotation).normalized()
	
	return direction

func _handle_wall_jump_force(current_velocity: Vector3, current_wall_normal: Vector3) -> Vector3:
	var wall_push = current_wall_normal * _wall_push_force
	var velocity = current_velocity + (Vector3.UP * _force) + wall_push
	
	return velocity

func _handle_wall_jump(current_velocity: Vector3, direction: Vector3, speed: float, delta: float) -> Vector3:
	var velocity = Vector3.ZERO
	if direction.is_zero_approx():
		velocity = current_velocity.move_toward(current_velocity + (Vector3.DOWN * _gravity), _acceleration * delta)
	else:
		velocity = current_velocity.move_toward((direction * speed) + (Vector3.DOWN * _gravity), _acceleration * delta)
	
	return velocity
