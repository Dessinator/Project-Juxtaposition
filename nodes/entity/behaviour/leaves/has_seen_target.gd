extends ConditionLeaf

func tick(_actor: Node, blackboard: BHBlackboard) -> int:
	var has_seen_target = blackboard.get_value("has_seen_target")
	if has_seen_target:
		return SUCCESS
	return FAILURE
