extends ActionLeaf

@onready var _entity_wander_range: EntityRange = %EntityWanderRange

func tick(_actor: Node, blackboard: BHBlackboard) -> int:
	var target_position = blackboard.get_value("target_position")
	_entity_wander_range.position = target_position
	
	return SUCCESS
