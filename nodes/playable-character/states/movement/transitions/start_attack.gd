@tool
extends FSMTransition

# handles the transition from * -> attack

func _on_transition(_delta: float, _actor: Node, _blackboard: BTBlackboard) -> void:
	pass

func is_valid(actor: Node, _blackboard: BTBlackboard) -> bool:
	actor = actor as PlayableCharacter
	
	return Input.is_action_just_pressed("attack")
