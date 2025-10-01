@tool
extends FSMTransition

# handles the transition from * -> heavy_charge_attack

# Evaluates true, if the transition conditions are met.
func is_valid(_actor: Node, blackboard: BTBlackboard) -> bool:
	return blackboard.get_value("holding_heavy_attack_input")
