@tool
extends FSMTransition

# handles the transition from * -> jogging

func is_valid(actor: Node, blackboard: BTBlackboard) -> bool:
	actor = actor as PlayableCharacter
	
	if not actor.is_on_floor():
		return false
		
	if blackboard.get_value("auto_jog"):
		if blackboard.get_value("is_targeting"):
			var direction = Input.get_vector("strafe_left", "strafe_right", "forwards", "backwards")
			if direction.y > 0:
				return false
	else:
		return false
	
	var character_container = actor.get_playable_character_character_container()
	var current_character = character_container.get_current_character()
	var stats = current_character.get_character_stats()
	var status = current_character.get_character_status()
	
	if Input.is_action_pressed("sprint") and (not status.is_exhausted()):
		return false
	
	return Input.is_action_pressed("move")
