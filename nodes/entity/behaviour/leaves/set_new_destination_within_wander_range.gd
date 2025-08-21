extends ActionLeaf

@onready var _entity_wander_range: EntityRange = %EntityWanderRange
@onready var _navigation_agent_3d: NavigationAgent3D = %NavigationAgent3D

func tick(actor: Node, blackboard: BHBlackboard):
	var range = _entity_wander_range.get_current_range()
	var destination = _get_random_pos_in_sphere(range) + _entity_wander_range.global_position
	
	_navigation_agent_3d.target_position = destination
	
	return SUCCESS

func _get_random_pos_in_sphere(radius: float) -> Vector3:
	var x1 = randf_range(-1, 1)
	var x2 = randf_range(-1, 1)

	while x1 * x1 + x2 * x2 >= 1:
		x1 = randf_range(-1, 1)
		x2 = randf_range(-1, 1)

	var random_pos_on_unit_sphere = Vector3 (
		2 * x1 * sqrt (1 - x1*x1 - x2*x2),
		2 * x2 * sqrt (1 - x1*x1 - x2*x2),
		1 - 2 * (x1*x1 + x2*x2))

	return random_pos_on_unit_sphere * randf_range(0, radius)
