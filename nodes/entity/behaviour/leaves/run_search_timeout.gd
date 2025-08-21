extends ActionLeaf

func tick(_actor: Node, blackboard: BHBlackboard):
	var ticks_left = blackboard.get_value("search_timeout", -1, Entity.TIMEOUT_BLACKBOARD)
	var new_ticks_value = ticks_left - 1
	if new_ticks_value < 0:
		new_ticks_value = 0
	
	blackboard.set_value("search_timeout", new_ticks_value, Entity.TIMEOUT_BLACKBOARD)
	print(new_ticks_value)
	return SUCCESS
