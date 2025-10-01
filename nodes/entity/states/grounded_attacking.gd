@tool
extends EntityState

@onready var _entity_combat_manager: EntityCombatManager = %EntityCombatManager
@onready var _attack_cooldown_timer: Timer = %AttackCooldownTimer

@export var damage: int
@export var can_dodge: bool
@export var can_parry: bool

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as Entity
	
	var target_node = actor.player
	var status_interface = target_node.get_node("%StatusInterface") as StatusInterface
	if status_interface == null:
		_handle_transitions(actor, blackboard)
		return
	
	_entity_combat_manager.deal_damage(status_interface, damage, can_dodge, can_parry)
	
	actor.velocity = Vector3.ZERO
	_attack_cooldown_timer.start()
	await _attack_cooldown_timer.timeout
	
	_handle_transitions(actor, blackboard)

# Executes every _process call, if the state is active.
func _on_update(_delta: float, _actor: Node, _blackboard: BTBlackboard) -> void:
	pass

# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: BTBlackboard) -> void:
	pass

func _handle_transitions(actor: Entity, blackboard: BTBlackboard):
	if not actor.is_on_floor():
		get_parent().fire_event(ON_START_FALLING)
		return
	
	var input_direction: Vector3 = _behaviour_tree_blackboard.get_value("input_direction", Vector3.ZERO, Entity.INPUT_BLACKBOARD)
	var input_sprinting: bool = _behaviour_tree_blackboard.get_value("input_sprinting", false, Entity.INPUT_BLACKBOARD)
	
	if (actor.velocity.is_zero_approx()) and input_direction.is_zero_approx():
		get_parent().fire_event(ON_START_IDLING)
		return
	
	if input_sprinting:
		get_parent().fire_event(ON_START_SPRINTING)
		return
	
	get_parent().fire_event(ON_START_WALKING)
