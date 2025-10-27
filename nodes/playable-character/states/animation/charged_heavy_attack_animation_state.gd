@tool
extends PlayableCharacterAnimationState


# Executes after the state is entered.
func _on_enter(_actor: Node, blackboard: BTBlackboard) -> void:
	var animation_name = blackboard.get_value(CURRENT_ATTACK_ANIMATION_NAME)
	character_animation_tree_expression_base.travel_to(animation_name)
	# _update_character_animation_tree_expression_base()

# func _update_character_animation_tree_expression_base():
