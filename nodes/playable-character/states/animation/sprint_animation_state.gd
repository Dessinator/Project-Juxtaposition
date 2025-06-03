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

func _on_update(_delta: float, actor: Node, _blackboard: BTBlackboard) -> void:
	_normalized_direction = _handle_direction_input()
	_character_animation_tree_expression_base.set_movement_vector(
		_normalized_direction,
		CharacterAnimationTreeExpressionBase.CharacterAnimationMovementLevel.LEVEL_SPRINT
	)

func _handle_direction_input() -> Vector2:
	var input_direction = Input.get_vector("strafe_left", "strafe_right", "forwards", "backwards")
	var direction = Vector2(input_direction.x, input_direction.y)
	
	return direction
