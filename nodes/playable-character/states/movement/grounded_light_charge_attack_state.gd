@tool
extends PlayableCharacterGameplayState

const ATTACK_STAT: StringName = &"attack"
const ATTACK_DAMAGE_STAT: StringName = &"attack_damage"

@onready var _light_charge_attack_timer: Timer = %LightChargeAttackTimer
@onready var _playable_character_combat_manager: PlayableCharacterCombatManager = %PlayableCharacterCombatManager

@export var _damage_multiplier: float = 1

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	super(actor, blackboard)
	actor = actor as PlayableCharacter
	
	actor.velocity = Vector3.ZERO
	
	_light_charge_attack_timer.timeout.connect(_on_light_charge_attack_timer_timeout.bind(actor, blackboard))
	_light_charge_attack_timer.start()
	
# Executes every _process call, if the state is active.
func _on_update(_delta: float, actor: Node, blackboard: BTBlackboard) -> void:
	if blackboard.get_value("holding_light_attack_input"):
		return
	
	_light_charge_attack_timer.stop()
	_handle_transitions(actor, blackboard)

# Executes before the state is exited.
func _on_exit(actor: Node, _blackboard: BTBlackboard) -> void:
	_light_charge_attack_timer.timeout.disconnect(_on_light_charge_attack_timer_timeout)

func _on_light_charge_attack_timer_timeout(actor: PlayableCharacter, blackboard: BTBlackboard):
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
	
	var midair_manager = target_node.get_node("%LaunchController") as LaunchController
	if status_interface == null:
		_handle_transitions(actor, blackboard)
		return
	midair_manager.launch()
	var launch_force_vector = midair_manager.handle_launch_force()
	blackboard.set_value("launch_force_vector", launch_force_vector)
	get_parent().fire_event(ON_START_SELF_LAUNCH)

func _handle_damage(actor: PlayableCharacter) -> int:
	var character_container = actor.get_playable_character_character_container()
	var current_character = character_container.get_current_character()
	var stats = current_character.get_character_stats()
	var attack_stat = stats.get_stat(ATTACK_STAT)
	var attack_value = attack_stat.get_value(false)
	var attack_damage_stat = stats.get_substat(ATTACK_DAMAGE_STAT)
	var attack_damage_value = attack_damage_stat.sample(attack_value, false)
	var damage = int(attack_damage_value + 0.5) / 10
	
	return damage

func _handle_transitions(actor: PlayableCharacter, blackboard: BTBlackboard):
	if not actor.is_on_floor():
		get_parent().fire_event(ON_START_FALLING)
		return
	
	if not Input.is_action_pressed("move"):
		get_parent().fire_event(ON_START_IDLING)
		return
	
	var character_container = actor.get_playable_character_character_container()
	var current_character = character_container.get_current_character()
	var status = current_character.get_character_status()
	
	if Input.is_action_pressed("sprint") and (not status.is_exhausted()):
		get_parent().fire_event(ON_START_SPRINTING)
		return
	
	if blackboard.get_value(AUTO_JOG):
		get_parent().fire_event(ON_START_JOGGING)
		return
	
	get_parent().fire_event(ON_START_WALKING)
