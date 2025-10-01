@tool
class_name PlayableCharacterGameplayState
extends FSMState

const AUTO_JOG: String = "auto_jog"
const IS_TARGETING: String = "is_targeting"
const TRACKED_TARGET_POSITION: String = "tracked_target_position"
const CAN_ARIAL_DODGE: String = "can_arial_dodge"
const REGENERATE_STAMINA: String = "regenerate_stamina"

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

enum GameplayStateSetValueMode
{
	MODE_DONT_CHANGE,
	MODE_SET_TRUE,
	MODE_SET_FALSE
}

@onready var _playable_character_character_container: PlayableCharacterCharacterContainer = %PlayableCharacterCharacterContainer
@onready var _camera: PlayableCharacterCamera = %PlayableCharacterCamera
@onready var _animation_finite_state_machine: FiniteStateMachine = %AnimationFiniteStateMachine
@onready var _transitions: Array = get_children()
@onready var _stamina_regeneration_delay_timer: Timer = %StaminaRegenerationDelayTimer

var _character: Character

@export var _set_can_arial_dodge: GameplayStateSetValueMode = GameplayStateSetValueMode.MODE_DONT_CHANGE
@export var _can_regenerate_stamina: bool = false
@export var _can_switch_characters: bool = true
@export var _animation_state: PlayableCharacterAnimationState
@export var _gameplay_action_visual_packedscene: PackedScene

func _enter_tree() -> void:
	%PlayableCharacterCharacterContainer.current_character_changed.connect(_on_current_character_changed)

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	
	actor._can_switch_characters = _can_switch_characters
	
	match _set_can_arial_dodge:
		GameplayStateSetValueMode.MODE_SET_TRUE:
			blackboard.set_value(CAN_ARIAL_DODGE, true)
		GameplayStateSetValueMode.MODE_SET_FALSE:
			blackboard.set_value(CAN_ARIAL_DODGE, false)
	
	if not _can_regenerate_stamina:
		_stamina_regeneration_delay_timer.stop()
		blackboard.set_value(REGENERATE_STAMINA, false)
	else:
		_handle_stamina_regeneration_delay(blackboard)
	
	if _animation_state:
		_animation_finite_state_machine.change_state(_animation_state)

# Executes every _process call, if the state is active.
func _on_update(_delta: float, _actor: Node, _blackboard: BTBlackboard) -> void:
	pass

# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: BTBlackboard) -> void:
	if _can_regenerate_stamina:
		_stamina_regeneration_delay_timer.timeout.disconnect(_on_stamina_regeneration_delay_timer_timeout)

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
