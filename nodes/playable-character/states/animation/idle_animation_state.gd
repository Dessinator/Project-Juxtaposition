@tool
extends PlayableCharacterAnimationState

var _is_targeting: bool

func _on_enter(_actor: Node, _blackboard: BTBlackboard) -> void:
	_update_character_animation_tree_expression_base()

func _on_update(_delta: float, _actor: Node, blackboard: BTBlackboard) -> void:
	_is_targeting = blackboard.get_value("is_targeting")

func _update_character_animation_tree_expression_base():
	if _is_targeting:
		_character_animation_tree_expression_base.travel_to_targeting_movement()
	else:
		_character_animation_tree_expression_base.travel_to_non_targeting_movement()
	
	_character_animation_tree_expression_base.set_movement_vector(
		Vector2.ZERO,
		CharacterAnimationTreeExpressionBase.CharacterAnimationMovementLevel.LEVEL_WALK
	)
