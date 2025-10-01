extends ActionLeaf

@onready var _state_machine: FiniteStateMachine = %StateMachine

func tick(actor: Node, _blackboard: BHBlackboard):
	actor = actor as Entity
	
	_state_machine.fire_event("on_attack")
	
	return SUCCESS
