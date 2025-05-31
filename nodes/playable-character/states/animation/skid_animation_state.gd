@tool
extends FSMState

@export var _character: Character

var _normalized_direction: Vector2

@onready var _character_animation_tree_expression_base: CharacterAnimationTreeExpressionBase = _character.get_node("%CharacterAnimationTreeExpressionBase")

func _on_enter(_actor: Node, _blackboard: BTBlackboard) -> void:
	_character_animation_tree_expression_base.travel_to_skid()
