@tool
extends FSMTransition

# handles the transition from * -> dodge

@onready var _dodge_state: Node = %DodgeState

# Evaluates true, if the transition conditions are met.
func is_valid(actor: Node, _blackboard: BTBlackboard) -> bool:
	actor = actor as PlayableCharacter
	
	var status = actor.get_status()
	var stamina_drain = _dodge_state.get_stamina_drain()
	var stamina = status.get_stamina()
	
	if stamina - stamina_drain < 0:
		return false
	
	return Input.is_action_just_pressed("dodge")
