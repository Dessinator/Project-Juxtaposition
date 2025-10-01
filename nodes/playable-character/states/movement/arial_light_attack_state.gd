@tool
extends PlayableCharacterGameplayState

const ATTACK_STAT: StringName = &"attack"
const ATTACK_DAMAGE_STAT: StringName = &"attack_damage"

@onready var _playable_character_combat_manager: PlayableCharacterCombatManager = %PlayableCharacterCombatManager
@onready var _airborne_timer: Timer = %AirborneTimer

@export var _damage_multiplier: float = 1
@export var _stamina_drain: float

@export var _gravity: float
@export var _acceleration: int = 40
@export var _boost_force: float

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	super(actor, blackboard)
	actor = actor as PlayableCharacter
	
	_handle_starting_airborne_timer()
	
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
	
	var character_container = actor.get_playable_character_character_container()
	var current_character = character_container.get_current_character()
	var character_status = current_character.get_character_status()
	character_status.exhaust(_stamina_drain)
	
	# give a boost up
	actor.velocity += Vector3.UP * _boost_force
	await get_tree().create_timer(0.5).timeout
	
	_handle_transitions(actor, blackboard)
	
# Executes every _process call, if the state is active.
func _on_update(delta: float, actor: Node, _blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	
	var velocity = _handle_falling(actor.velocity, delta)
	actor.velocity = velocity

# Executes before the state is exited.
func _on_exit(actor: Node, _blackboard: BTBlackboard) -> void:
	_airborne_timer.timeout.disconnect(_on_airborne_timer_timeout)

func _handle_starting_airborne_timer():
	_airborne_timer.timeout.connect(_on_airborne_timer_timeout)
	if not _airborne_timer.is_stopped():
		var new_time = _airborne_timer.time_left + 1.5
		if new_time > _airborne_timer.wait_time:
			new_time = _airborne_timer.wait_time
		_airborne_timer.start(new_time)
		return
	_airborne_timer.start()

func _handle_falling(current_velocity: Vector3, delta: float) -> Vector3:
	var velocity = current_velocity.move_toward(Vector3.DOWN * _gravity, _acceleration * delta)
	return velocity

func _handle_transitions(actor: PlayableCharacter, blackboard: BTBlackboard):
	get_parent().fire_event(ON_START_AIRBORNE)

func _on_airborne_timer_timeout():
	pass
