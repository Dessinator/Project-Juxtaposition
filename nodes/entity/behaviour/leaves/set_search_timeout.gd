extends ActionLeaf

@export var ticks: int = 2000

func tick(_actor: Node, blackboard: BHBlackboard):
	blackboard.set_value("search_timeout", ticks, Entity.TIMEOUT_BLACKBOARD)
	return SUCCESS
