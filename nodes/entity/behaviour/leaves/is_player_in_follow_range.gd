extends ConditionLeaf

func tick(_actor: Node, blackboard: BHBlackboard) -> int:
	var is_player_in_follow_range = blackboard.get_value("is_player_in_follow_range", false)
	if is_player_in_follow_range:
		return SUCCESS
	return FAILURE
