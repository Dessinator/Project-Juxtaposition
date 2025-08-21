extends ActionLeaf

# will turn the EntityModelContainer to face the position "target_position"
# on the blackboard. Position should be global.

@onready var _entity_model_container: Node3D = %EntityModelContainer

func tick(actor: Node, blackboard: BHBlackboard):
	actor = actor as Entity
	
	var target_position = blackboard.get_value("target_position", Vector3.ZERO)
	var local_target_position = target_position - actor.global_position
	var direction = local_target_position.normalized()

	_entity_model_container.rotation.y = atan2(direction.x, direction.z)
	
	return SUCCESS
