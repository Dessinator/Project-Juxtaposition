class_name UIRenderHandler
extends Control

signal playable_character_gameplay_ui_changed
signal playable_character_gameplay_ui_updated

@onready var _game_manager: GameManager = $".."
@onready var _playable_character_gameplay_ui_container: Control = %PlayableCharacterGameplayUIMarginContainer

var _playable_character: PlayableCharacter
var _current_playable_character_gameplay_ui: PlayableCharacterGameplayUI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_playable_character = _game_manager.get_playable_character()
	var gameplay_ui = _playable_character.get_playable_character_gameplay_ui_packedscene()
	
	_update_playable_character_gameplay_ui(gameplay_ui)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_playable_character_gameplay_ui_container() -> Control:
	return _playable_character_gameplay_ui_container

# handles switching gameplay ui for a PlayableCharacter node.
func _update_playable_character_gameplay_ui(playable_character_gameplay_ui_packedscene: PackedScene):
	if _current_playable_character_gameplay_ui:
		_current_playable_character_gameplay_ui.queue_free()
	
	_current_playable_character_gameplay_ui = playable_character_gameplay_ui_packedscene.instantiate()
	_playable_character_gameplay_ui_container.add_child(_current_playable_character_gameplay_ui)
	
