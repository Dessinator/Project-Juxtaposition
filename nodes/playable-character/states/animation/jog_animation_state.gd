@tool
extends PlayableCharacterAnimationState

const IS_TARGETING: String = "is_targeting"

var _is_targeting: bool
var _normalized_direction: Vector2

func _on_enter(_actor: Node, _blackboard: BTBlackboard) -> void:
	_update_character_animation_tree_expression_base()

func _on_update(_delta: float, actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	
	_is_targeting = blackboard.get_value(IS_TARGETING)
	_normalized_direction = _handle_direction(actor.get_relative_direction())
	
	_update_character_animation_tree_expression_base()

func _handle_direction(relative_direction: Vector3) -> Vector2:
	var direction = Vector2(relative_direction.x, -relative_direction.z)
	return direction

func _update_character_animation_tree_expression_base():
	if _is_targeting:
		_character_animation_tree_expression_base.travel_to_targeting_movement()
	else:
		_character_animation_tree_expression_base.travel_to_non_targeting_movement()
	_character_animation_tree_expression_base.set_movement_vector(
		_normalized_direction,
		CharacterAnimationTreeExpressionBase.CharacterAnimationMovementLevel.LEVEL_JOG
	)
