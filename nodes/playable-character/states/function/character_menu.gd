@tool
extends FSMState

const PLAYABLE_CHARACTER_CHARACTER_STAGE_SCENE: PackedScene = preload("res://nodes/playable-character/components/playable-character-character-stage/playable_character_character_stage.tscn")
const PLAYABLE_CHARACTER_CHARACTER_UI_SCENE: PackedScene = preload("res://nodes/playable-character/components/playable-character-character-ui/playable_character_character_ui.tscn")

const CLOSE_CHARACTER_MENU_EVENT: String = "close_character_menu"

@onready var _playable_character_character_container: PlayableCharacterCharacterContainer = %PlayableCharacterCharacterContainer

@onready var _gameplay_finite_state_machine: FiniteStateMachine = %GameplayFiniteStateMachine
@onready var _idle_state: PlayableCharacterGameplayState = %IdleState
@onready var _animation_finite_state_machine: FiniteStateMachine = %AnimationFiniteStateMachine

var _playable_character_character_stage_instance: PlayableCharacterCharacterStage
var _playable_character_character_ui_instance: PlayableCharacterCharacterUI

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
	_playable_character_character_stage_instance = PLAYABLE_CHARACTER_CHARACTER_STAGE_SCENE.instantiate()
	actor.get_parent().add_child(_playable_character_character_stage_instance)
	if not _playable_character_character_stage_instance.is_node_ready():
		await _playable_character_character_stage_instance.ready
	_playable_character_character_stage_instance.global_position = actor.global_position
	_playable_character_character_ui_instance = PLAYABLE_CHARACTER_CHARACTER_UI_SCENE.instantiate()

	# switch to character menu ui
	game_manager.get_ui_render_handler().set_ui_scene(_playable_character_character_ui_instance)
	if not _playable_character_character_ui_instance.is_node_ready():
		await _playable_character_character_ui_instance.ready
	_setup_playable_character_character_ui_instance()

	# set stage camera as current
	var camera = _playable_character_character_stage_instance.get_node("%TrackballCamera")
	game_manager.get_world_render_handler().set_current_camera(camera)

	# set current inspected character to current active character
	var character = _playable_character_character_container.get_current_character()
	var nonplayable_character = _playable_character_character_stage_instance.character_stage_nonplayable_character
	character.reparent(nonplayable_character.nonplayable_character_character_container, false)

	_playable_character_character_ui_instance.current_character = character

	# connect the character_changed signal after setting current_character so that we can
	# update the stage with the new character and return the old character to the playable
	# character character container
	_playable_character_character_ui_instance.character_changed.connect(_on_playable_character_character_ui_instance_character_changed)


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
	var character = _playable_character_character_ui_instance.current_character

	# if this isnt the current character, just remove child
	if character == _playable_character_character_container.get_current_character():
		character.reparent(_playable_character_character_container, false)
	else:
		var nonplayable_character = _playable_character_character_stage_instance.character_stage_nonplayable_character
		nonplayable_character.nonplayable_character_character_container.remove_child(character)

	# free the stage
	_playable_character_character_stage_instance.queue_free()

func _setup_playable_character_character_ui_instance():
	_setup_character_picker_icon_buttons()

func _setup_character_picker_icon_buttons():
	var characters = _playable_character_character_container.get_characters()
	
	for character in characters:
		_playable_character_character_ui_instance.add_character_picker_icon_button(character)


func _on_playable_character_character_ui_instance_character_changed(old: Character, new: Character):
	if old:

		# if this isnt the current character, just remove child
		if old == _playable_character_character_container.get_current_character():
			old.reparent(_playable_character_character_container, false)
		else:
			var nonplayable_character = _playable_character_character_stage_instance.character_stage_nonplayable_character
			nonplayable_character.nonplayable_character_character_container.remove_child(old)
	
	var nonplayable_character = _playable_character_character_stage_instance.character_stage_nonplayable_character

	# if this was the current character, reparent. otherwise add child
	if new == _playable_character_character_container.get_current_character():
		new.reparent(nonplayable_character.nonplayable_character_character_container, false)
		return
	
	nonplayable_character.nonplayable_character_character_container.add_child(new)

func _handle_transitions() -> bool:
	if Input.is_action_just_pressed("close_menu"):
		get_parent().fire_event(CLOSE_CHARACTER_MENU_EVENT)
		return true
	
	return false
