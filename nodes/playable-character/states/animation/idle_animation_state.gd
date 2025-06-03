@tool
extends FSMState

@export var _character: Character

var _normalized_direction: Vector2

@onready var _character_animation_tree_expression_base: CharacterAnimationTreeExpressionBase = _character.get_node("%CharacterAnimationTreeExpressionBase")

func _on_enter(_actor: Node, blackboard: BTBlackboard) -> void:
	if blackboard.get_value("is_targeting"):
		_character_animation_tree_expression_base.travel_to_targeting_movement()
	else:
		_character_animation_tree_expression_base.travel_to_non_targeting_movement()
	_character_animation_tree_expression_base.set_movement_vector(
		Vector2.ZERO,
		CharacterAnimationTreeExpressionBase.CharacterAnimationMovementLevel.LEVEL_WALK
	)
