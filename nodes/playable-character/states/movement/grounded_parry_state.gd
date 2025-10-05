@tool
extends PlayableCharacterGameplayState

const ATTACK_STAT: StringName = &"attack"
const ATTACK_DAMAGE_STAT: StringName = &"attack_damage"

@onready var _playable_character_combat_manager: PlayableCharacterCombatManager = %PlayableCharacterCombatManager
@onready var _parry_time_timer: Timer = %ParryTimeTimer

@export var _damage_multiplier: float = 0.25
@export var _slow_motion: float
@export var _slow_motion_fade_time: float = 1

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	super(actor, blackboard)
	actor = actor as PlayableCharacter
	
	actor.velocity = Vector3.ZERO
	
	var interrupted_damage_instance = blackboard.get_value("interrupted_damage_instance")
	var status_interface = interrupted_damage_instance.source.get_node("%StatusInterface") as StatusInterface
	if status_interface == null:
		_handle_transitions(actor, blackboard.get_value(AUTO_JOG))
		return
	
	_playable_character_combat_manager.deal_damage(status_interface, _damage_multiplier, false, false)
	
	_set_slow_motion(_slow_motion)
	var tween = get_tree().create_tween()
	tween.tween_method(_set_slow_motion, _slow_motion, 1.0, _slow_motion_fade_time)
	
	_parry_time_timer.timeout.connect(_on_parry_time_timer_timer_timeout.bind(actor, blackboard.get_value("auto_jog")))
	_parry_time_timer.start()

# Executes every _process call, if the state is active.
func _on_update(_delta: float, _actor: Node, _blackboard: BTBlackboard) -> void:
	pass

# Executes before the state is exited.
func _on_exit(actor: Node, blackboard: BTBlackboard) -> void:
	super(actor, blackboard)
	blackboard.set_value("interrupted_damage_instance", null)
	_parry_time_timer.timeout.disconnect(_on_parry_time_timer_timer_timeout)

func _set_slow_motion(slow_motion: float):
	Engine.time_scale = slow_motion

func _on_parry_time_timer_timer_timeout(playable_character: PlayableCharacter, auto_jog: bool):
	_handle_transitions(playable_character, auto_jog)

func _handle_transitions(playable_character: PlayableCharacter, auto_jog: bool):
	if not playable_character.is_on_floor():
		get_parent().fire_event(ON_START_FALLING)
		return
	
	if Input.is_action_pressed("move"):
		if Input.is_action_pressed("sprint"):
			get_parent().fire_event(ON_START_SPRINTING)
			return
		if auto_jog:
			get_parent().fire_event(ON_START_JOGGING)
			return
		
		get_parent().fire_event(ON_START_WALKING)
		return
	
	get_parent().fire_event(ON_START_IDLING)
