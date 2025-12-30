class_name UIRenderHandler
extends Control

var _game_manager: GameManager
var _playable_character: PlayableCharacter
var _playable_character_visual_controller: PlayableCharacterVisualController

var _current_ui_scene: Control:
	set(value):
		if _current_ui_scene:
			%UIScenePanelContainer.remove_child(_current_ui_scene)
		
		_current_ui_scene = value
		%UIScenePanelContainer.add_child(_current_ui_scene)
		
@onready var _ui_scene_panel_container: PanelContainer = %UIScenePanelContainer
@onready var _cinematic_bars: CinematicBars = %CinematicBars

func initialize(game_manager: GameManager) -> void:
	_game_manager = game_manager
	
	# _playable_character = _game_manager.get_playable_character()
	# _playable_character_visual_controller = _playable_character.get_playable_character_visual_controller()
	# var playable_character_gameplay_ui = _playable_character_visual_controller.get_new_playable_character_gameplay_ui_instance()
	# set_ui_scene(playable_character_gameplay_ui)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_ui_scene(ui_scene: Control):
	_current_ui_scene = ui_scene

func get_cinematic_bars() -> CinematicBars:
	return _cinematic_bars
