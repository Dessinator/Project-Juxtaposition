extends ActionLeaf

func tick(_actor: Node, blackboard: BHBlackboard):
	blackboard.set_value("input_direction", Vector3.ZERO, Entity.INPUT_BLACKBOARD)
	return SUCCESS
