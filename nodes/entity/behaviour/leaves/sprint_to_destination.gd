extends ActionLeaf

# return RUNNING until destination set on the NavigationAgent3D has been reached.

@onready var _navigation_agent_3d: NavigationAgent3D = %NavigationAgent3D

func tick(actor: Node, blackboard: BHBlackboard):
	actor = actor as Entity
	
	if _navigation_agent_3d.is_navigation_finished():
		blackboard.set_value("input_sprinting", false, Entity.INPUT_BLACKBOARD)
		blackboard.set_value("input_direction", Vector3.ZERO, Entity.INPUT_BLACKBOARD)
		return SUCCESS
	
	var next_path_position = _navigation_agent_3d.get_next_path_position()
	var local_next_path_position = next_path_position - actor.global_position
	var input_direction = Vector3(local_next_path_position.x, 0, local_next_path_position.z).normalized()
	
	blackboard.set_value("input_sprinting", true, Entity.INPUT_BLACKBOARD)
	blackboard.set_value("input_direction", input_direction, Entity.INPUT_BLACKBOARD)
	
	return RUNNING
