extends ActionLeaf

@onready var _entity_follow_range: EntityRange = %EntityFollowRange

func tick(_actor: Node, blackboard: BHBlackboard) -> int:
	var new_range = _entity_follow_range.max_range
	_entity_follow_range.set_current_range(new_range)
	
	return SUCCESS
