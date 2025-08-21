extends ActionLeaf

@export var _seen: bool = true

func tick(_actor: Node, blackboard: BHBlackboard) -> int:
	blackboard.set_value("has_seen_target", _seen)
	return SUCCESS
