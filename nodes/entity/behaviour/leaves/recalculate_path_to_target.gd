extends ActionLeaf

@onready var _navigation_agent_3d: NavigationAgent3D = %NavigationAgent3D

func tick(_actor: Node, blackboard: BHBlackboard):
	var target_position = blackboard.get_value("target_position")
	_navigation_agent_3d.target_position = target_position
	
	return SUCCESS
