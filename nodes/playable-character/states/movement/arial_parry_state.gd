@tool
extends PlayableCharacterGameplayState

const ATTACK_STAT: StringName = &"attack"
const ATTACK_DAMAGE_STAT: StringName = &"attack_damage"

@onready var _playable_character_combat_manager: PlayableCharacterCombatManager = %PlayableCharacterCombatManager
@onready var _airborne_timer: Timer = %AirborneTimer
@onready var _parry_time_timer: Timer = %ParryTimeTimer

@export var _damage_multiplier: float = 1

@export var _gravity: float
@export var _acceleration: int = 40
@export var _force: float = 10.0
@export var _boost_force: float

@export var _slow_motion: float
@export var _slow_motion_fade_time: float = 1

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	super(actor, blackboard)
	actor = actor as PlayableCharacter
	
	# give a boost up
	actor.velocity += Vector3.UP * _boost_force
	
	var interrupted_damage_instance = blackboard.get_value("interrupted_damage_instance")
	var status_interface = interrupted_damage_instance.source.get_node("%StatusInterface") as StatusInterface
	if status_interface == null:
		_handle_transitions()
		return
	
	_playable_character_combat_manager.deal_damage(status_interface, _damage_multiplier, false, false)
	
	_set_slow_motion(_slow_motion)
	var tween = get_tree().create_tween()
	tween.tween_method(_set_slow_motion, _slow_motion, 1.0, _slow_motion_fade_time)
	
	_handle_starting_airborne_timer()
	_parry_time_timer.timeout.connect(_on_parry_time_timer_timer_timeout)
	_parry_time_timer.start()

# Executes every _process call, if the state is active.
func _on_update(delta: float, actor: Node, _blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	
	var velocity = _handle_falling(actor.velocity, delta)
	actor.velocity = velocity

# Executes before the state is exited.
func _on_exit(actor: Node, blackboard: BTBlackboard) -> void:
	super(actor, blackboard)
	blackboard.set_value("interrupted_damage_instance", null)
	_parry_time_timer.timeout.disconnect(_on_parry_time_timer_timer_timeout)

func _handle_falling(current_velocity: Vector3, delta: float) -> Vector3:
	var velocity = current_velocity.move_toward(Vector3.DOWN * _gravity, _acceleration * delta)
	return velocity

func _handle_starting_airborne_timer():
	if not _airborne_timer.is_stopped():
		var new_time = _airborne_timer.time_left + 1.5
		if new_time > _airborne_timer.wait_time:
			new_time = _airborne_timer.wait_time
		_airborne_timer.start(new_time)
		return
	_airborne_timer.start()

func _set_slow_motion(slow_motion: float):
	Engine.time_scale = slow_motion

func _on_parry_time_timer_timer_timeout():
	_handle_transitions()

func _handle_transitions():
	if _airborne_timer.is_stopped():
		get_parent().fire_event(ON_START_FALLING)
		return
	get_parent().fire_event(ON_START_AIRBORNE)
