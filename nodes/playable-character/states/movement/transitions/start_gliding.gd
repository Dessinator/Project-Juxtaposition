@tool
extends FSMTransition


# Executed when the transition is taken.
func _on_transition(_delta: float, _actor: Node, _blackboard: BTBlackboard) -> void:
	pass


# Evaluates true, if the transition conditions are met.
func is_valid(actor: Node, _blackboard: BTBlackboard) -> bool:
	actor = actor as PlayableCharacter
	
	if actor.get_status().is_exhausted():
		return false
	
	if actor.get_last_slide_collision():
		return false
	
	return Input.is_action_just_pressed("glide")


# Add custom configuration warnings
# Note: Can be deleted if you don't want to define your own warnings.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array = []

	warnings.append_array(super._get_configuration_warnings())

	# Add your own warnings to the array here

	return warnings
