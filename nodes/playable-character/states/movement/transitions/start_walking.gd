@tool
extends FSMTransition

# handles the transition from * -> walking

func _on_transition(_delta: float, _actor: Node, _blackboard: BTBlackboard) -> void:
	pass

func is_valid(actor: Node, blackboard: BTBlackboard) -> bool:
	actor = actor as PlayableCharacter
	
	if not actor.is_on_floor():
		return false
	
	var character_container = actor.get_playable_character_character_container()
	var character = character_container.get_current_character()
	var status = character.get_character_status()
	
	if blackboard.get_value("auto_jog"):
		if blackboard.get_value("is_targeting"):
			if Input.is_action_pressed("sprint") and (not status.is_exhausted()):
				return false
			var direction = Input.get_vector("strafe_left", "strafe_right", "forwards", "backwards")
			if direction.y > 0:
				return true
		return false
	
	if Input.is_action_pressed("sprint") and (not status.is_exhausted()):
		return false
	
	return Input.is_action_pressed("move")
