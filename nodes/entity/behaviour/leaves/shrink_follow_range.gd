extends ActionLeaf

@onready var _entity_follow_range: EntityRange = %EntityFollowRange

@export var _rate: float = 0.01

func tick(_actor: Node, blackboard: BHBlackboard) -> int:
	var new_range = _entity_follow_range.get_current_range() - _rate
	_entity_follow_range.set_current_range(new_range)
	
	return SUCCESS
