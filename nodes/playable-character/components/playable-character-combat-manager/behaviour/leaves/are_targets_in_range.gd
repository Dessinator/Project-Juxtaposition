extends ConditionLeaf

func tick(actor: Node, _blackboard: BHBlackboard) -> int:
	actor = actor as PlayableCharacterCombatManager
	
	var range = actor.target_range
	var targets = range.targets_in_range
	
	if targets.is_empty():
		return FAILURE
	return SUCCESS
