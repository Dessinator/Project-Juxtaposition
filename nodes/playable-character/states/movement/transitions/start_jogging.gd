@tool
extends FSMTransition

# handles the transition from * -> jogging

func is_valid(actor: Node, blackboard: BTBlackboard) -> bool:
	actor = actor as PlayableCharacter
	
	if not actor.is_on_floor():
		return false
	
	var character_container = actor.get_playable_character_character_container()
	var current_character = character_container.get_current_character()
	var stats = current_character.get_character_stats()
	var status = current_character.get_character_status()
	
	if Input.is_action_pressed("sprint") and (not status.is_exhausted()):
		return false
	
	if not blackboard.get_value("auto_jog"):
		return false
		
	if blackboard.get_value("is_targeting"):
		var relative_direction = actor.get_relative_direction()
		if relative_direction.z < 0:
			return false
	
	return Input.is_action_pressed("move")
