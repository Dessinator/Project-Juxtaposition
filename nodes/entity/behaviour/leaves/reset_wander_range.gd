extends ActionLeaf

@onready var _entity_home_range: EntityRange = %EntityHomeRange
@onready var _entity_wander_range: EntityRange = %EntityWanderRange

func tick(_actor: Node, _blackboard: BHBlackboard) -> int:
	_entity_wander_range.global_position = _entity_home_range.global_position
	_entity_wander_range.set_current_range(_entity_wander_range.range)
	
	return SUCCESS
