@tool
extends PlayableCharacterAnimationState


# Executes after the state is entered.
func _on_enter(_actor: Node, _blackboard: BTBlackboard) -> void:
	_update_character_animation_tree_expression_base()

func _update_character_animation_tree_expression_base():
	character_animation_tree_expression_base.travel_to_charged_light_attack()
