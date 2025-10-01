@tool
extends EntityState

@onready var _damage_taken_timer: Timer = %DamageTakenTimer

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as Entity
	
	actor.velocity = Vector3.ZERO
	
	_damage_taken_timer.timeout.connect(_on_damage_taken_timer_timeout.bind(actor, blackboard))
	_damage_taken_timer.start()

# Executes every _process call, if the state is active.
func _on_update(_delta: float, _actor: Node, _blackboard: BTBlackboard) -> void:
	pass


# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: BTBlackboard) -> void:
	_damage_taken_timer.timeout.disconnect(_on_damage_taken_timer_timeout)

func _on_damage_taken_timer_timeout(actor: Entity, blackboard: BTBlackboard):
	_handle_transitions(actor, blackboard)

func _handle_transitions(actor: Entity, blackboard: BTBlackboard):
	if not actor.is_on_floor():
		get_parent().fire_event(ON_START_FALLING)
		return
	
	var behaviour_tree_blackboard = actor.get_behaviour_tree().blackboard
	var input_sprinting: bool = behaviour_tree_blackboard.get_value("input_sprinting", false, Entity.INPUT_BLACKBOARD)
	var input_direction: Vector3 = behaviour_tree_blackboard.get_value("input_direction", Vector3.ZERO, Entity.INPUT_BLACKBOARD)
	
	if input_direction.is_zero_approx():
		get_parent().fire_event(ON_START_IDLING)
		return
	
	if input_sprinting:
		get_parent().fire_event(ON_START_SPRINTING)
		return
	
	get_parent().fire_event(ON_START_WALKING)
