@tool
extends FSMState

const PLAYABLE_CHARACTER_PARTY_STAGE_SCENE: PackedScene = preload("res://nodes/playable-character/components/playable-character-party-stage/playable_character_party_stage.tscn")
const PLAYABLE_CHARACTER_PARTY_UI_SCENE: PackedScene = preload("res://nodes/playable-character/components/playable-character-party-ui/playable_character_party_ui.tscn")

const CLOSE_PARTY_MENU_EVENT: String = "close_party_menu"

@onready var _playable_character_character_container: PlayableCharacterCharacterContainer = %PlayableCharacterCharacterContainer

@onready var _gameplay_finite_state_machine: FiniteStateMachine = %GameplayFiniteStateMachine
@onready var _idle_state: PlayableCharacterGameplayState = %IdleState
@onready var _animation_finite_state_machine: FiniteStateMachine = %AnimationFiniteStateMachine

var _playable_character_party_stage_instance: PlayableCharacterPartyStage
var _playable_character_party_ui_instance: PlayableCharacterPartyUI

# Executes after the state is entered.
func _on_enter(actor: Node, _blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	_gameplay_finite_state_machine.change_state(_idle_state)

	if _gameplay_finite_state_machine.active:
		_gameplay_finite_state_machine.active = false
	if _animation_finite_state_machine.active:
		_animation_finite_state_machine.active = false
	
	# First prevent the playable character from doing anything while the character menu is loading/active.
	actor.velocity = Vector3.ZERO

	var game_manager = GameManager.get_instance()

	# make world mesh, entities and playable character invisible
	game_manager.get_current_world_mesh().visible = false
	actor.visible = false
	for entity in get_tree().get_nodes_in_group("entities"):
		entity.visible = false

	# instantiate the stage and ui
	_playable_character_party_stage_instance = PLAYABLE_CHARACTER_PARTY_STAGE_SCENE.instantiate()
	actor.get_parent().add_child(_playable_character_party_stage_instance)
	if not _playable_character_party_stage_instance.is_node_ready():
		await _playable_character_party_stage_instance.ready
	_playable_character_party_stage_instance.global_position = actor.global_position
	_playable_character_party_ui_instance = PLAYABLE_CHARACTER_PARTY_UI_SCENE.instantiate()

	# switch to character menu ui
	game_manager.get_ui_render_handler().set_ui_scene(_playable_character_party_ui_instance)
	if not _playable_character_party_ui_instance.is_node_ready():
		await _playable_character_party_ui_instance.ready
	# _setup_playable_character_party_ui_instance()

	# set stage camera as current
	var camera = _playable_character_party_stage_instance.get_node("%Camera3D")
	game_manager.get_world_render_handler().set_current_camera(camera)

	# reparent all characters in the current party to the nonplayable characters
	var characters = _playable_character_character_container.get_characters()
	for i in range(characters.size()):
		var character = characters[i]
		var nonplayable_character = _playable_character_party_stage_instance.nonplayable_characters[i]
		if character.is_inside_tree():
			character.reparent(nonplayable_character.nonplayable_character_character_container, false)
			continue
		
		nonplayable_character.nonplayable_character_character_container.add_child(character)

# Executes every _process call, if the state is active.
func _on_update(_delta: float, _actor: Node, _blackboard: BTBlackboard) -> void:
	var transitioned = _handle_transitions()

# Executes before the state is exited.
func _on_exit(actor: Node, _blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	
	if not _gameplay_finite_state_machine.active:
		_gameplay_finite_state_machine.active = true
	if not _animation_finite_state_machine.active:
		_animation_finite_state_machine.active = true

	var game_manager = GameManager.get_instance()

	# make world mesh, entities and playable character visible again
	game_manager.get_current_world_mesh().visible = true
	actor.visible = true
	for entity in get_tree().get_nodes_in_group("entities"):
		entity.visible = true

	# return character to playable character
	var characters = _playable_character_character_container.get_characters()
	for i in range(characters.size()):
		var character = characters[i]
		var nonplayable_character = _playable_character_party_stage_instance.nonplayable_characters[i]
		if character == _playable_character_character_container.get_current_character():
			character.reparent(_playable_character_character_container, false)
			continue
		
		nonplayable_character.nonplayable_character_character_container.remove_child(character)

	# free the stage
	_playable_character_party_stage_instance.queue_free()

func _handle_transitions() -> bool:
	if Input.is_action_just_pressed("close_menu"):
		get_parent().fire_event(CLOSE_PARTY_MENU_EVENT)
		return true
	
	return false
