@tool
extends FSMTransition

# handles the transition from * -> sprinting

func _on_transition(_delta: float, _actor: Node, _blackboard: BTBlackboard) -> void:
	pass

func is_valid(actor: Node, _blackboard: BTBlackboard) -> bool:
	actor = actor as PlayableCharacter
	
	if not actor.is_on_floor():
		return false
	
	if actor.get_status().is_exhausted():
		return false
	
	return Input.is_action_pressed("move") and Input.is_action_pressed("sprint")
