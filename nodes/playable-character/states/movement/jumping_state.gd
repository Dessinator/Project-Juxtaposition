@tool
extends FSMState

@export var _vertical_force: float = 15
@export var _horizontal_force: float = 2
@export var _gravity: float = 9.8
@export var _acceleration: float = 40.0
@export var _speed: float

@export var _camera: PlayableCharacterCamera
@export var _character: Character

@onready var _character_visual: Node3D = %CharacterVisual

@onready var _animation_finite_state_machine: FiniteStateMachine = %AnimationFiniteStateMachine
@onready var _jump_animation_state: Node = %JumpAnimationState

@onready var _stamina_regeneration_delay_timer: Timer = %StaminaRegenerationDelayTimer

func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	
	_stamina_regeneration_delay_timer.stop()
	blackboard.set_value("regenerate_stamina", false)
	
	var velocity = _handle_jump_force(actor.velocity)
	actor.velocity = velocity
	
	_animation_finite_state_machine.change_state(_jump_animation_state)

func _on_update(delta: float, actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	
	var horizontal_camera_rotation = _camera.get_horizontal_rotation()
	var direction = _handle_direction_input(horizontal_camera_rotation)
	var velocity = _handle_jumping(actor.velocity, direction, _speed, delta)
	if velocity.y < 0:
		get_parent().fire_event("on_start_falling")
		return
	
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	
	actor.velocity = velocity
	if not horizontal_velocity.is_zero_approx():
		var horizontal_velocity_normalized = horizontal_velocity.normalized()
		_character.rotation.y = atan2(horizontal_velocity_normalized.x, horizontal_velocity_normalized.z)

func _on_exit(_actor: Node, _blackboard: BTBlackboard) -> void:
	pass

func _handle_direction_input(horizontal_rotation: float) -> Vector3:
	var input_direction = Input.get_vector("strafe_left", "strafe_right", "forwards", "backwards")
	var direction = Vector3(input_direction.x, 0, input_direction.y)
	direction = direction.rotated(Vector3.UP, horizontal_rotation).normalized()
	
	return direction

func _handle_jump_force(current_velocity: Vector3) -> Vector3:
	var velocity = Vector3(
		current_velocity.x * _horizontal_force,
		_vertical_force,
		current_velocity.z * _horizontal_force
	)
	
	return velocity

func _handle_jumping(current_velocity: Vector3, direction: Vector3, speed: float, delta: float) -> Vector3:
	var velocity = Vector3.ZERO
	if direction.is_zero_approx():
		velocity = current_velocity.move_toward((current_velocity.normalized() * speed) + (Vector3.DOWN * _gravity), _acceleration * delta)
	else:
		velocity = current_velocity.move_toward((direction * speed) + (Vector3.DOWN * _gravity), _acceleration * delta)
	
	return velocity
