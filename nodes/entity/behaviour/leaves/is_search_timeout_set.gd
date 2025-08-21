extends ConditionLeaf

func tick(_actor: Node, blackboard: BHBlackboard):
	var search_timeout = blackboard.get_value("search_timeout", -1.0, Entity.TIMEOUT_BLACKBOARD)
	
	# search timeout not set if == -1.0
	if search_timeout == -1.0:
		return FAILURE
	return SUCCESS
