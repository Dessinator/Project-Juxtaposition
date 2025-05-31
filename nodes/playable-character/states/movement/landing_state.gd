@tool
extends FSMState

@onready var _animation_finite_state_machine: FiniteStateMachine = %AnimationFiniteStateMachine
@onready var _landing_animation_state: Node = %LandingAnimationState

func _on_enter(actor: Node, _blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	_animation_finite_state_machine.change_state(_landing_animation_state)
	
	actor.velocity.y = 0
	
	if not Input.is_action_pressed("move"):
		actor.velocity = Vector3.ZERO

func _on_update(_delta: float, _actor: Node, _blackboard: BTBlackboard) -> void:
	pass

func _on_exit(_actor: Node, _blackboard: BTBlackboard) -> void:
	pass
