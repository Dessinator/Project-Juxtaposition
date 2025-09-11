extends ConditionLeaf

func tick(_actor: Node, blackboard: BHBlackboard) -> int:
	if not blackboard.has_value("tracked_target_position"):
		return FAILURE
	return SUCCESS
