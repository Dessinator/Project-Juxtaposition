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
	actor = actor as PlayableCharacter
	
	_normalized_direction = _handle_direction_input(actor)
	_character_animation_tree_expression_base.set_movement_vector(
		_normalized_direction,
		CharacterAnimationTreeExpressionBase.CharacterAnimationMovementLevel.LEVEL_WALK
	)

func _handle_direction_input(playable_character: PlayableCharacter) -> Vector2:
	var direction = Input.get_vector("strafe_left", "strafe_right", "forwards", "backwards")
	if not playable_character._gameplay_blackboard.get_value("is_targeting"):
		if direction.y > -1:
			direction.y = -1
	
	return direction
