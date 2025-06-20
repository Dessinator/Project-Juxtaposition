class_name UIRenderHandler
extends Control

var _game_manager: GameManager
var _playable_character: PlayableCharacter
var _playable_character_visual_controller: PlayableCharacterVisualController
var _current_playable_character_gameplay_ui: PlayableCharacterGameplayUI

@onready var _playable_character_gameplay_ui_container: Control = %PlayableCharacterGameplayUIMarginContainer

func initialize(game_manager: GameManager) -> void:
	_game_manager = game_manager
	
	_playable_character = _game_manager.get_playable_character()
	_playable_character_visual_controller = _playable_character.get_playable_character_visual_controller()
	_current_playable_character_gameplay_ui = _playable_character_visual_controller.get_new_playable_character_gameplay_ui_instance()
	
	_playable_character_gameplay_ui_container.add_child(_current_playable_character_gameplay_ui)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_playable_character_gameplay_ui_container() -> Control:
	return _playable_character_gameplay_ui_container
	
