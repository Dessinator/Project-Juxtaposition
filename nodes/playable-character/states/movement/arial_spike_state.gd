@tool
extends PlayableCharacterGameplayState

const ATTACK_STAT: StringName = &"attack"
const ATTACK_DAMAGE_STAT: StringName = &"attack_damage"

@onready var _airborne_timer: Timer = %AirborneTimer
@onready var _heavy_charge_attack_timer: Timer = %HeavyChargeAttackTimer
@onready var _playable_character_combat_manager: PlayableCharacterCombatManager = %PlayableCharacterCombatManager

@export var _damage_multiplier: float = 1
@export var _stamina_drain: float

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	super(actor, blackboard)
	actor = actor as PlayableCharacter
	
	_handle_starting_airborne_timer()
	
	actor.velocity = Vector3.ZERO
	
	_heavy_charge_attack_timer.timeout.connect(_on_heavy_charge_attack_timer_timeout.bind(actor, blackboard))
	_heavy_charge_attack_timer.start()
	
# Executes every _process call, if the state is active.
func _on_update(_delta: float, actor: Node, blackboard: BTBlackboard) -> void:
	if blackboard.get_value("holding_heavy_attack_input"):
		return
	
	_heavy_charge_attack_timer.stop()
	actor.emit_action_interrupted(_action_type)
	_handle_transitions(actor, blackboard)

# Executes before the state is exited.
func _on_exit(actor: Node, blackboard: BTBlackboard) -> void:
	super(actor, blackboard)
	_heavy_charge_attack_timer.timeout.disconnect(_on_heavy_charge_attack_timer_timeout)
	_airborne_timer.timeout.disconnect(_on_airborne_timer_timeout)

func _handle_starting_airborne_timer():
	_airborne_timer.timeout.connect(_on_airborne_timer_timeout)
	if not _airborne_timer.is_stopped():
		return
	_airborne_timer.start()

func _on_heavy_charge_attack_timer_timeout(actor: PlayableCharacter, blackboard: BTBlackboard):
	var tracked_target = _playable_character_combat_manager.get_tracked_target()
	if tracked_target == null:
		_handle_transitions(actor, blackboard)
		return
	
	var target_node = tracked_target.get_parent()
	var status_interface = target_node.get_node("%StatusInterface") as StatusInterface
	if status_interface == null:
		_handle_transitions(actor, blackboard)
		return
	_playable_character_combat_manager.deal_damage(status_interface, _damage_multiplier)
	
	_handle_transitions(actor, blackboard)
	
	var midair_manager = target_node.get_node("%LaunchController") as LaunchController
	if status_interface == null:
		_handle_transitions(actor, blackboard)
		return
	midair_manager.spike()
	
	actor.velocity = Vector3.ZERO
	await get_tree().create_timer(0.5).timeout
	get_parent().fire_event(ON_START_AIRBORNE)

func _handle_transitions(actor: PlayableCharacter, blackboard: BTBlackboard):
	get_parent().fire_event(ON_START_AIRBORNE)

func _on_airborne_timer_timeout():
	pass
