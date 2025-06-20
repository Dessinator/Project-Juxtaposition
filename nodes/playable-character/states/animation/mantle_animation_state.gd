@tool
extends PlayableCharacterAnimationState

func _on_enter(_actor: Node, _blackboard: BTBlackboard) -> void:
	_character_animation_tree_expression_base.travel_to_mantle()
