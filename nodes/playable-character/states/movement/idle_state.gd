@tool
extends FSMState

@onready var _animation_finite_state_machine: FiniteStateMachine = %AnimationFiniteStateMachine
@onready var _idle_animation_state: Node = %IdleAnimationState

@onready var _stamina_regeneration_delay_timer: Timer = %StaminaRegenerationDelayTimer

func _on_enter(_actor: Node, blackboard: BTBlackboard) -> void:
	_animation_finite_state_machine.change_state(_idle_animation_state)
	
	_handle_stamina_regeneration_delay(blackboard)

func _on_update(_delta: float, _actor: Node, _blackboard: BTBlackboard) -> void:
	pass

func _on_exit(_actor: Node, _blackboard: BTBlackboard) -> void:
	_stamina_regeneration_delay_timer.timeout.disconnect(_on_stamina_regeneration_delay_timer_timeout)
	pass

#func _handle_stamina_regen_delay(status: CharacterStatus):
	#var stamina = status.get_stamina()
	#var max_stamina = status.get_max_stamina()
	#
	#if stamina >= max_stamina:
		#return
	#
	#if _stamina_regen_delay_timer.is_stopped():
		#_stamina_regen_delay_timer.timeout.connect(_handle_stamina_regen)
		#_stamina_regen_delay_timer.start()

func _handle_stamina_regeneration_delay(blackboard: BTBlackboard):
	_stamina_regeneration_delay_timer.timeout.connect(_on_stamina_regeneration_delay_timer_timeout.bind(blackboard))
	if not blackboard.get_value("regenerate_stamina") and _stamina_regeneration_delay_timer.is_stopped():
		blackboard.set_value("regenerate_stamina", false)
		_stamina_regeneration_delay_timer.start()

func _on_stamina_regeneration_delay_timer_timeout(blackboard: BTBlackboard):
	blackboard.set_value("regenerate_stamina", true)
