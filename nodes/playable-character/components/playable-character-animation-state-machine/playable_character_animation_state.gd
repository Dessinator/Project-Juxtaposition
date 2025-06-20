@tool
class_name PlayableCharacterAnimationState
extends FSMState

@export var _character: Character

var _character_animation_tree_expression_base: CharacterAnimationTreeExpressionBase

@onready var _playable_character_character_container: PlayableCharacterCharacterContainer = %PlayableCharacterCharacterContainer

func _enter_tree() -> void:
	%PlayableCharacterCharacterContainer.current_character_changed.connect(_on_current_character_changed)

# anything that manipulates CharacterAnimationTreeExpressionBase should go in here.
func _update_character_animation_tree_expression_base():
	pass

func _on_current_character_changed(_old: Character, new: Character):
	_set_character(new)

func _set_character(character: Character):
	_character = character
	_character_animation_tree_expression_base = _character.get_node("%CharacterAnimationTreeExpressionBase")
	
	if $"..".active_state == self:
		_update_character_animation_tree_expression_base()
