extends ConditionLeaf

@onready var _status_interface: StatusInterface = %StatusInterface

func tick(_actor: Node, _blackboard: BHBlackboard):
	var status = _status_interface.get_status()
	if status.is_dead():
		return SUCCESS
	return FAILURE
