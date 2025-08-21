extends ActionLeaf

@onready var _entity_follow_range: EntityRange = %EntityFollowRange

func tick(_actor: Node, _blackboard: BHBlackboard) -> int:
	_entity_follow_range.set_current_range(_entity_follow_range.range)
	
	return SUCCESS
