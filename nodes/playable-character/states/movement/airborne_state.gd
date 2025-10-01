@tool
extends PlayableCharacterGameplayState

@onready var _airborne_timer: Timer = %AirborneTimer

@export var _horizontal_speed: float
@export var _gravity: float
@export var _acceleration: int = 40

func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	super(actor, blackboard)
	_handle_starting_airborne_timer()

func _on_update(delta: float, actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	
	var exhausted = _handle_exhaustion(actor)
	if exhausted:
		return
	
	var horizontal_camera_rotation = _camera.get_horizontal_rotation()
	var direction = _handle_direction_input(horizontal_camera_rotation)
	var velocity = _handle_falling(actor.velocity, direction, delta)
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	
	actor.velocity = velocity
	if not horizontal_velocity.is_zero_approx():
		var horizontal_velocity_normalized = horizontal_velocity.normalized()
		_playable_character_character_container.rotation.y = atan2(horizontal_velocity_normalized.x, horizontal_velocity_normalized.z)
	
	_handle_targeting(actor, blackboard)

# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: BTBlackboard) -> void:
	_airborne_timer.timeout.disconnect(_on_airborne_timer_timeout)

func _handle_starting_airborne_timer():
	_airborne_timer.timeout.connect(_on_airborne_timer_timeout)
	if not _airborne_timer.is_stopped():
		return
	_airborne_timer.start()

func _handle_exhaustion(actor: PlayableCharacter):
	var character_container = actor.get_playable_character_character_container()
	var current_character = character_container.get_current_character()
	var character_status = current_character.get_character_status()
	var is_exhausted = character_status.is_exhausted()
	if is_exhausted:
		get_parent().fire_event(ON_START_FALLING)
	return is_exhausted

func _handle_direction_input(horizontal_rotation: float) -> Vector3:
	var input_direction = Input.get_vector("strafe_left", "strafe_right", "forwards", "backwards")
	var direction = Vector3(input_direction.x, 0, input_direction.y)
	direction = direction.rotated(Vector3.UP, horizontal_rotation).normalized()
	
	return direction

func _handle_falling(current_velocity: Vector3, direction: Vector3, delta: float) -> Vector3:
	var velocity = current_velocity.move_toward((direction * _horizontal_speed) + (Vector3.DOWN * _gravity), _acceleration * delta)
	return velocity

func _handle_targeting(actor: PlayableCharacter, blackboard: BTBlackboard):
	var character_animation_tree_expression_base = _character.get_node("%CharacterAnimationTreeExpressionBase")
	
	if not blackboard.get_value(IS_TARGETING):
		character_animation_tree_expression_base.travel_to_non_targeting_movement()
		return
	
	var tracked_target_position = blackboard.get_value(TRACKED_TARGET_POSITION)
	if tracked_target_position == null:
		return
	character_animation_tree_expression_base.travel_to_targeting_movement()
	var direction = tracked_target_position - actor.global_position
	var rotation = atan2(direction.x, direction.z)
	_playable_character_character_container.rotation.y = rotation

func _on_airborne_timer_timeout():
	get_parent().fire_event(ON_START_FALLING)
