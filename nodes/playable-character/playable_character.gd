class_name PlayableCharacter
extends CharacterBody3D

const STAMINA_REGENERATION_INTERVAL: float = 0.5

const AGILITY: StringName = &"agility"
const STAMINA_REGENERATION_RATE: StringName = &"stamina_regeneration_rate"

@export var debug_no_animations: bool
@export var _character: Character

var _character_attack_state_machine: CharacterAttackStateMachine

var _status: CharacterStatus
var _stats: CharacterStats

var _stamina_regeneration_timer: float = STAMINA_REGENERATION_INTERVAL

@onready var _playable_character_stamina_meter: PlayableCharacterStaminaMeter = %PlayableCharacterStaminaMeter

@onready var _gameplay_finite_state_machine: FiniteStateMachine = %GameplayFiniteStateMachine
@onready var _animation_finite_state_machine: FiniteStateMachine = %AnimationFiniteStateMachine
@onready var _gameplay_blackboard: BTBlackboard = _gameplay_finite_state_machine.blackboard

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	_character_attack_state_machine = _character.get_character_attack_state_machine().instantiate()
	add_child(_character_attack_state_machine)
	_character_attack_state_machine.actor = self
	
	_stats = _character.get_character_stats()
	_reset_status()
	
	_playable_character_stamina_meter.initialize(_status)
	
	_start_state_machines()

func _physics_process(delta: float) -> void:
	move_and_slide()

func _process(delta: float) -> void:
	_gameplay_blackboard.set_value("auto_jog", _handle_toggle_auto_jog(_gameplay_blackboard.get_value("auto_jog")))
	
	_handle_stamina_regeneration(_gameplay_blackboard.get_value("regenerate_stamina"), delta)

func get_character_attack_state_machine() -> CharacterAttackStateMachine:
	return _character_attack_state_machine

func get_character() -> Character:
	return _character
func get_status() -> CharacterStatus:
	return _status

func _reset_status():
	_status = CharacterStatus.new()

	_status.died.connect(_on_died)

	#_status.status_effect_applied.connect(_visual_manager._on_status_effect_applied)
	#_status.status_effect_stack_applied.connect(_visual_manager._status_effect_stack_applied)
	#_status.status_effect_ticked.connect(_visual_manager._status_effect_ticked)
	#_status.status_effect_stack_removed.connect(_visual_manager._status_effect_stack_removed)
	#_status.status_effect_removed.connect(_visual_manager._on_status_effect_removed)
#
	#_status.damaged.connect(_visual_manager._on_damaged)
	#_status.healed.connect(_visual_manager._on_healed)
#
	#_visual_manager._actor_status = _status

	_status.initialize(self, _stats)

func _start_state_machines():
	_character_attack_state_machine.start()
	if debug_no_animations:
		_animation_finite_state_machine.start()
	_gameplay_finite_state_machine.start()

func _handle_toggle_auto_jog(auto_jog: bool) -> bool:
	if not Input.is_action_just_pressed("jog"):
		return auto_jog
	
	return not auto_jog

func _handle_stamina_regeneration(regenerate_stamina: bool, delta: float):
	if _status.is_stamina_max():
		return
	if not regenerate_stamina:
		return
	if _stamina_regeneration_timer <= 0:
		var agility_stat = _stats.get_stat(AGILITY)
		var agility_value = agility_stat.get_value(false)
		var stamina_regeneration_rate_stat = _stats.get_substat(STAMINA_REGENERATION_RATE)
		var stamina_regeneration_rate_value = stamina_regeneration_rate_stat.sample(agility_value, false)
		
		_status.rest(stamina_regeneration_rate_value)
		_stamina_regeneration_timer = STAMINA_REGENERATION_INTERVAL
	
	_stamina_regeneration_timer -= delta
	

func _on_died():
	pass
