extends ConditionLeaf

func tick(_actor: Node, blackboard: BHBlackboard) -> int:
	var is_staying = blackboard.get_value("is_staying", false)
	
	if is_staying:
		return SUCCESS
	return FAILURE
