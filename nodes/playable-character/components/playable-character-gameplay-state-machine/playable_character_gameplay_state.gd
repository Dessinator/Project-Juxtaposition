@tool
class_name PlayableCharacterGameplayState
extends FSMState

const AUTO_JOG: String = "auto_jog"
const CAN_ARIAL_DODGE: String = "can_arial_dodge"
const REGENERATE_STAMINA: String = "regenerate_stamina"

const IS_TARGETING: String = "is_targeting"
const TRACKED_TARGET_POSITION: String = "tracked_target_position"

const CURRENT_ATTACK_PHASE: String = "current_attack_phase"
const CURRENT_GROUNDED_LIGHT_ATTACK_PHASE: String = "current_grounded_light_attack_phase"
const CURRENT_ARIAL_LIGHT_ATTACK_PHASE: String = "current_arial_light_attack_phase"
const CURRENT_GROUNDED_HEAVY_ATTACK_PHASE: String = "current_grounded_heavy_attack_phase"
const CURRENT_ARIAL_HEAVY_ATTACK_PHASE: String = "current_arial_heavy_attack_phase"

const ON_START_IDLING: String = "on_start_idling"
const ON_START_WALKING: String = "on_start_walking"
const ON_START_JOGGING: String = "on_start_jogging"
const ON_START_SPRINTING: String = "on_start_sprinting"
const ON_START_SKIDDING: String = "on_start_skidding"
const ON_START_JUMPING: String = "on_start_jumping"
const ON_START_FALLING: String = "on_start_falling"
const ON_START_LANDING: String = "on_start_landing"
const ON_START_GROUNDED_PARRY: String = "on_start_grounded_parry"
const ON_START_GROUNDED_DODGE: String = "on_start_grounded_dodge"
const ON_START_GROUNDED_LIGHT_ATTACK: String = "on_start_grounded_light_attack"
const ON_START_GROUNDED_LIGHT_CHARGE_ATTACK: String = "on_start_grounded_light_charge_attack"
const ON_START_GROUNDED_HEAVY_ATTACK: String = "on_start_grounded_heavy_attack"
const ON_START_GROUNDED_HEAVY_CHARGE_ATTACK: String = "on_start_grounded_heavy_charge_attack"
const ON_START_SELF_LAUNCH: String = "on_start_self_launch"
const ON_START_LAUNCH: String = "on_start_launch"
const ON_START_AIRBORNE: String = "on_start_airborne"
const ON_START_ARIAL_PARRY: String = "on_start_arial_parry"
const ON_START_ARIAL_DODGE: String = "on_start_arial_dodge"
const ON_START_ARIAL_LIGHT_ATTACK: String = "on_start_arial_light_attack"
const ON_START_ARIAL_LIGHT_CHARGE_ATTACK: String = "on_start_arial_light_charge_attack"
const ON_START_ARIAL_HEAVY_ATTACK: String = "on_start_arial_heavy_attack"
const ON_START_ARIAL_SPIKE: String = "on_start_arial_spike"
const ON_START_SPIKE: String = "on_start_spike"
const ON_START_WALLRUN: String = "on_start_wallrun"
const ON_START_WALLSLIDE: String = "on_start_wallslide"
const ON_START_MANTLE: String = "on_start_mantle"
const ON_START_SWING: String = "on_start_swing"
const ON_START_WALL_JUMP: String = "on_start_wall_jump"
const ON_START_GROUNDED_JUX_PARRY: String = "on_start_grounded_jux-parry"
const ON_START_GROUNDED_JUX_DODGE: String = "on_start_grounded_jux-dodge"

enum PlayableCharacterActionType
{
	TYPE_OTHER,
	TYPE_DODGE,
	TYPE_PARRY,
	TYPE_JUMP,
	TYPE_LIGHT_ATTACK,
	TYPE_HEAVY_ATTACK,
	TYPE_JUXTAPOSE
}
enum GameplayStateSetValueMode
{
	MODE_DONT_CHANGE,
	MODE_SET_TRUE,
	MODE_SET_FALSE
}

@onready var _playable_character_character_container: PlayableCharacterCharacterContainer = %PlayableCharacterCharacterContainer
@onready var _playable_character_mover: PlayableCharacterMover = %PlayableCharacterMover
@onready var _camera: PlayableCharacterCamera = %PlayableCharacterCamera
@onready var _animation_finite_state_machine: FiniteStateMachine = %AnimationFiniteStateMachine
@onready var _transitions: Array = get_children()
@onready var _stamina_regeneration_delay_timer: Timer = %StaminaRegenerationDelayTimer

var _character: Character

@export_subgroup("Functionality")
@export var _set_can_arial_dodge: GameplayStateSetValueMode = GameplayStateSetValueMode.MODE_DONT_CHANGE
@export var _can_regenerate_stamina: bool = false
@export var _can_switch_characters: bool = true

@export_subgroup("Visuals")
@export var _animation_state: PlayableCharacterAnimationState
@export var _auto_switch_animation_state: bool = true
@export var _action_type: PlayableCharacterActionType = PlayableCharacterActionType.TYPE_OTHER
@export var _hold_action: bool = false
@export var _set_action_unavailable: bool = false
@export var _set_action_unavailable_duration: float = 0
@export var _set_action_available_duration: float = 0
@export var _action_types_modifiers: Array[ActionTypeAvailabilityModifier]

func _enter_tree() -> void:
	%PlayableCharacterCharacterContainer.current_character_changed.connect(_on_current_character_changed)

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	
	_handle_can_switch_characters(actor)
	_handle_can_arial_dodge(blackboard)
	_handle_can_regenerate_stamina(blackboard)
	_handle_animation_state_change()
	_handle_action_performed(actor)
	_handle_action_availability(actor)

# Executes every _process call, if the state is active.
func _on_update(_delta: float, _actor: Node, _blackboard: BTBlackboard) -> void:
	pass

# Executes before the state is exited.
func _on_exit(actor: Node, _blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	
	_handle_action_conclusion(actor)
	
	if _can_regenerate_stamina:
		_stamina_regeneration_delay_timer.timeout.disconnect(_on_stamina_regeneration_delay_timer_timeout)

func _handle_can_switch_characters(playable_character: PlayableCharacter):
	playable_character._can_switch_characters = _can_switch_characters
func _handle_can_arial_dodge(blackboard: BTBlackboard):
	match _set_can_arial_dodge:
		GameplayStateSetValueMode.MODE_SET_TRUE:
			blackboard.set_value(CAN_ARIAL_DODGE, true)
		GameplayStateSetValueMode.MODE_SET_FALSE:
			blackboard.set_value(CAN_ARIAL_DODGE, false)
func _handle_can_regenerate_stamina(blackboard: BTBlackboard):
	if not _can_regenerate_stamina:
		_stamina_regeneration_delay_timer.stop()
		blackboard.set_value(REGENERATE_STAMINA, false)
	else:
		_handle_stamina_regeneration_delay(blackboard)

func _handle_animation_state_change():
	if not _auto_switch_animation_state:
		return
	
	if _animation_state:
		_animation_finite_state_machine.change_state(_animation_state)
func _handle_action_performed(playable_character: PlayableCharacter):
	playable_character.emit_action_performed(_action_type, _hold_action)
func _handle_action_conclusion(playable_character: PlayableCharacter):
	if not _hold_action:
		return
	playable_character.emit_action_concluded(_action_type)
func _handle_action_availability(playable_character: PlayableCharacter):
	if _set_action_unavailable:
		playable_character.emit_action_set_unavailable(_action_type)
	elif _set_action_unavailable_duration > 0:
		playable_character.emit_action_set_unavailable_duration(_action_type, _set_action_unavailable_duration)
	elif _set_action_available_duration > 0:
		playable_character.emit_action_set_available_duration(_action_type, _set_action_available_duration)
	
	if _action_types_modifiers.is_empty():
		return
	
	for _action_type_modifier in _action_types_modifiers:
		if _action_type_modifier.set_action_available:
			playable_character.emit_action_set_available(_action_type_modifier.action_type)
		elif _action_type_modifier.set_action_available_duration > 0:
			playable_character.emit_action_set_available_duration(_action_type_modifier.action_type, _action_type_modifier.set_action_available_duration)
		elif _action_type_modifier.set_action_unavailable:
			playable_character.emit_action_set_unavailable(_action_type_modifier.action_type)
		elif _action_type_modifier.set_action_unavailable_duration > 0:
			playable_character.emit_action_set_unavailable_duration(_action_type_modifier.action_type, _action_type_modifier.set_action_unavailable_duration)

func _on_current_character_changed(_old: Character, new: Character):
	_set_character(new)
func _set_character(character: Character):
	_character = character

func _handle_stamina_regeneration_delay(blackboard: BTBlackboard):
	if not _stamina_regeneration_delay_timer.timeout.is_connected(_on_stamina_regeneration_delay_timer_timeout):
		_stamina_regeneration_delay_timer.timeout.connect(_on_stamina_regeneration_delay_timer_timeout.bind(blackboard))
	if not blackboard.get_value("regenerate_stamina") and _stamina_regeneration_delay_timer.is_stopped():
		blackboard.set_value("regenerate_stamina", false)
		_stamina_regeneration_delay_timer.start()
func _on_stamina_regeneration_delay_timer_timeout(blackboard: BTBlackboard):
	blackboard.set_value("regenerate_stamina", true)
