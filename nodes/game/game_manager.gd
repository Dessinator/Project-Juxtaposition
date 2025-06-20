class_name GameManager
extends Node

@export var _playable_character: PlayableCharacter

@onready var _game_finite_state_machine: FiniteStateMachine = $GameFiniteStateMachine
@onready var _world_render_handler: WorldRenderHandler = %WorldRenderHandler
@onready var _ui_render_handler: UIRenderHandler = %UIRenderHandler

func _ready():
	_start_game_finite_state_machine()
	_initialize_world_render_handler()
	_initialize_ui_render_handler()

func get_playable_character() -> PlayableCharacter:
	return _playable_character

func get_world_render_handler() -> WorldRenderHandler:
	return _world_render_handler
func get_ui_render_handler() -> UIRenderHandler:
	return _ui_render_handler

func _start_game_finite_state_machine():
	_game_finite_state_machine.start()

func _initialize_world_render_handler():
	_world_render_handler.initialize(self)
func _initialize_ui_render_handler():
	_ui_render_handler.initialize(self)
