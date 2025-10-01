@tool
extends FSMTransition


# Executed when the transition is taken.
func _on_transition(_delta: float, _actor: Node, _blackboard: BTBlackboard) -> void:
	pass


# Evaluates true, if the transition conditions are met.
func is_valid(actor: Node, _blackboard: BTBlackboard) -> bool:
	actor = actor as PlayableCharacter
	
	var character_container = actor.get_playable_character_character_container()
	var character = character_container.get_current_character()
	var status = character.get_character_status()
	
	if status.is_dead():
		return false
	if status.is_juxtaposed():
		return false
	if not status.is_juxtometer_full():
		return false
	
	return Input.is_action_just_pressed("juxtapose")
