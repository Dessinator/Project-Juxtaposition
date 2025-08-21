@tool
extends FSMTransition

# handles the transition from * -> walking

@onready var _behaviour_tree_blackboard: BHBlackboard = %BehaviourTreeBlackboard

# Executed when the transition is taken.
func _on_transition(_delta: float, _actor: Node, _blackboard: BTBlackboard) -> void:
	pass


# Evaluates true, if the transition conditions are met.
func is_valid(actor: Node, _blackboard: BTBlackboard) -> bool:
	actor = actor as Entity
	
	if not actor.is_on_floor():
		return false
	
	var input_sprinting: bool = _behaviour_tree_blackboard.get_value("input_sprinting", false, Entity.INPUT_BLACKBOARD)
	var input_direction: Vector3 = _behaviour_tree_blackboard.get_value("input_direction", Vector3.ZERO, Entity.INPUT_BLACKBOARD)
	
	if input_sprinting:
		return false
	
	return not input_direction.is_zero_approx()

# Add custom configuration warnings
# Note: Can be deleted if you don't want to define your own warnings.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array = []

	warnings.append_array(super._get_configuration_warnings())

	# Add your own warnings to the array here

	return warnings
