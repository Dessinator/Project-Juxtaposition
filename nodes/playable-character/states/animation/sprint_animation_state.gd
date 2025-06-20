@tool
extends PlayableCharacterAnimationState

var _is_targeting: bool
var _normalized_direction: Vector2

func _on_enter(_actor: Node, blackboard: BTBlackboard) -> void:
	_update_character_animation_tree_expression_base()

func _on_update(_delta: float, actor: Node, blackboard: BTBlackboard) -> void:
	_is_targeting = blackboard.get_value("is_targeting")
	_normalized_direction = _handle_direction_input()
	
	_update_character_animation_tree_expression_base()

func _handle_direction_input() -> Vector2:
	var input_direction = Input.get_vector("strafe_left", "strafe_right", "forwards", "backwards")
	var direction = Vector2(input_direction.x, input_direction.y)
	
	return direction

func _update_character_animation_tree_expression_base():
	if _is_targeting:
		_character_animation_tree_expression_base.travel_to_targeting_movement()
	else:
		_character_animation_tree_expression_base.travel_to_non_targeting_movement()
	_character_animation_tree_expression_base.set_movement_vector(
		_normalized_direction,
		CharacterAnimationTreeExpressionBase.CharacterAnimationMovementLevel.LEVEL_SPRINT
	)
