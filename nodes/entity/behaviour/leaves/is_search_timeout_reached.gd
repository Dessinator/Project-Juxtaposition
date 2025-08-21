extends ConditionLeaf

func tick(_actor: Node, blackboard: BHBlackboard):
	var search_timeout = blackboard.get_value("search_timeout", -1.0, Entity.TIMEOUT_BLACKBOARD)
	
	# search timeout reached if == 0.0
	if search_timeout == 0.0:
		return SUCCESS
	return FAILURE
