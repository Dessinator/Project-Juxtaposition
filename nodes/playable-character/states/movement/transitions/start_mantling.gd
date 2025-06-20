@tool
extends FSMTransition


# Executed when the transition is taken.
func _on_transition(_delta: float, _actor: Node, _blackboard: BTBlackboard) -> void:
	pass


# Evaluates true, if the transition conditions are met.
func is_valid(actor: Node, _blackboard: BTBlackboard) -> bool:
	actor = actor as PlayableCharacter
	
	if not actor.is_on_wall():
		return false
	
	var mantle_ray_cast = actor.get_playable_character_character_container().get_current_character().get_mantle_ray_cast()
	if not mantle_ray_cast.is_colliding():
		return false
	
	return true


# Add custom configuration warnings
# Note: Can be deleted if you don't want to define your own warnings.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array = []

	warnings.append_array(super._get_configuration_warnings())

	# Add your own warnings to the array here

	return warnings
