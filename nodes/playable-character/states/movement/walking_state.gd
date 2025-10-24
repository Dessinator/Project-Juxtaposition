@tool
extends PlayableCharacterGameplayState

const AGILITY: StringName = &"agility"
const MOVEMENT_SPEED: StringName = &"movement_speed"

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	super(actor, blackboard)

# Executes every _process call, if the state is active.
func _on_update(_delta: float, actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	
	var horizontal_camera_rotation = _camera.get_horizontal_rotation()
	var direction = _handle_direction_input(horizontal_camera_rotation)
	
	_playable_character_mover.direction = direction
	_handle_targeting(actor, blackboard)

# Executes before the state is exited.
func _on_exit(actor: Node, blackboard: BTBlackboard) -> void:
	super(actor, blackboard)

func _handle_direction_input(horizontal_rotation: float) -> Vector3:
	var input_direction = Input.get_vector("strafe_left", "strafe_right", "forwards", "backwards")
	var direction = Vector3(input_direction.x, 0, input_direction.y)
	direction = direction.rotated(Vector3.UP, horizontal_rotation).normalized()
	
	return direction

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
