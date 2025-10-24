@tool
extends PlayableCharacterAnimationState

# Executes after the state is entered.
func _on_enter(_actor: Node, blackboard: BTBlackboard) -> void:
	var current_attack_phase = blackboard.get_value(CURRENT_ATTACK_PHASE)
	character_animation_tree_expression_base.travel_to_light_attack(current_attack_phase)

	# match current_attack_phase:
	# 	1:
	# 		_character_animation_tree_expression_base.travel_to_light_attack_1()
	# 	2: 
	# 		_character_animation_tree_expression_base.travel_to_light_attack_2()
	# 	3:
	# 		_character_animation_tree_expression_base.travel_to_light_attack_3()
	
	#_update_character_animation_tree_expression_base()

func _update_character_animation_tree_expression_base():
	pass
	#_character_animation_tree_expression_base.travel_to_light_attack_1()
