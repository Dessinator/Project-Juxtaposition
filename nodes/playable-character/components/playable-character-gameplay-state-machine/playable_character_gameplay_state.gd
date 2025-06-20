@tool
class_name PlayableCharacterGameplayState
extends FSMState

@export var _can_switch_characters: bool = true
@export var _animation_state: PlayableCharacterAnimationState
@export var _gameplay_action_visual_packedscene: PackedScene

var _character: Character

@onready var _playable_character_character_container: PlayableCharacterCharacterContainer = %PlayableCharacterCharacterContainer
@onready var _camera: PlayableCharacterCamera = %PlayableCharacterCamera
@onready var _animation_finite_state_machine: FiniteStateMachine = %AnimationFiniteStateMachine
@onready var _transitions: Array = get_children()

func _enter_tree() -> void:
	%PlayableCharacterCharacterContainer.current_character_changed.connect(_on_current_character_changed)

# Executes after the state is entered.
func _on_enter(actor: Node, _blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	
	actor._can_switch_characters = _can_switch_characters
	
	if _animation_state:
		_animation_finite_state_machine.change_state(_animation_state)

# Executes every _process call, if the state is active.
func _on_update(_delta: float, _actor: Node, _blackboard: BTBlackboard) -> void:
	pass

# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: BTBlackboard) -> void:
	pass

func _on_current_character_changed(_old: Character, new: Character):
	_set_character(new)

func _set_character(character: Character):
	_character = character
