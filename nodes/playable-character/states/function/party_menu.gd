@tool
extends FSMState

const PLAYABLE_CHARACTER_PARTY_STAGE_SCENE: PackedScene = preload("res://nodes/playable-character/components/playable-character-party-stage/playable_character_party_stage.tscn")
const PLAYABLE_CHARACTER_PARTY_UI_SCENE: PackedScene = preload("res://nodes/playable-character/components/playable-character-party-ui/playable_character_party_ui.tscn")

const CLOSE_PARTY_MENU_EVENT: String = "close_party_menu"
const OPEN_PARTY_MEMBER_DETAILS_MENU: String = "open_party_member_details_menu"

@onready var _playable_character_party_manager: PlayableCharacterPartyManager = %PlayableCharacterPartyManager
@onready var _playable_character_character_container: PlayableCharacterCharacterContainer = %PlayableCharacterCharacterContainer

@onready var _gameplay_finite_state_machine: FiniteStateMachine = %GameplayFiniteStateMachine
@onready var _idle_state: PlayableCharacterGameplayState = %IdleState
@onready var _animation_finite_state_machine: FiniteStateMachine = %AnimationFiniteStateMachine

var _playable_character_party_stage_instance: PlayableCharacterPartyStage
var _playable_character_party_ui_instance: PlayableCharacterPartyUI

var _saved_party: Party
var _tentative_party: Party:
	set(value):
		_tentative_party = value
		_playable_character_party_stage_instance.current_party = _tentative_party

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	actor.velocity = Vector3.ZERO
	actor.visible = false

	_set_gameplay_state_machine_active(false)
	_set_animation_state_machine_active(false)
	
	_set_environment_visible(false)

	var recovered = await _handle_recover_previous_state(actor.get_parent())
	if not recovered:
		_setup_stage(actor.get_parent(), actor.global_position)
		# await the stage ready signal
		if not _playable_character_party_stage_instance.is_node_ready():
			await _playable_character_party_stage_instance.ready
		_setup_ui()
		# await the ui ready signal
		if not _playable_character_party_ui_instance.is_node_ready():
			await _playable_character_party_ui_instance.ready
		
		_save_current_party()

		_setup_nonplayable_characters()
		
		# the stage should automatically update depending on what party is given
		_playable_character_party_stage_instance.current_party = _saved_party
		_playable_character_party_ui_instance.current_party = _saved_party

	_set_current_camera()

	_playable_character_party_ui_instance.character_details_requested.connect(_on_character_details_requested)
	_playable_character_party_ui_instance.quick_select_requested.connect(_on_quick_select_requested)
	_playable_character_party_ui_instance.party_deploy_requested.connect(_on_party_deploy_requested)
	_playable_character_party_ui_instance.close_requested.connect(_on_close_requested)

# Executes every _process call, if the state is active.
func _on_update(_delta: float, _actor: Node, _blackboard: BTBlackboard) -> void:
	var transitioned = _handle_transitions()

# Executes before the state is exited.
func _on_exit(actor: Node, _blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	# if viewing character details, do not free the stage and store the current ui
	# scene for reinstating later.
	if get_parent().blackboard.get_value("viewing_character_details"):
		_save_stage(actor.get_parent())
		_save_ui()

		return
	
	actor.visible = true

	_set_gameplay_state_machine_active(true)
	_set_animation_state_machine_active(true)

	_set_environment_visible(true)

	_playable_character_party_stage_instance.queue_free()


func _set_gameplay_state_machine_active(active: bool):
	if not active:
		_gameplay_finite_state_machine.change_state(_idle_state)
	_gameplay_finite_state_machine.active = active
func _set_animation_state_machine_active(active: bool):
	_animation_finite_state_machine.active = active

func _set_environment_visible(visible: bool):
	GameManager.get_instance().get_current_world_mesh().visible = visible
	for entity in get_tree().get_nodes_in_group("entities"):
		entity.visible = visible

# if viewing_character_details == true on the blackboard, recover the state
# saved in the blackboard.
func _handle_recover_previous_state(stage_parent: Node3D) -> bool:
	var blackboard = get_parent().blackboard
	if not blackboard.get_value("viewing_character_details"):
		return false
	
	_playable_character_party_stage_instance = blackboard.get_value("playable_character_party_stage_instance")
	stage_parent.add_child(_playable_character_party_stage_instance)
	if not _playable_character_party_stage_instance.is_node_ready():
		await _playable_character_party_stage_instance.ready
	
	_playable_character_party_ui_instance = blackboard.get_value("playable_character_party_ui_instance")
	GameManager.get_instance().get_ui_render_handler().set_ui_scene(_playable_character_party_ui_instance)
	if not _playable_character_party_ui_instance.is_node_ready():
		await _playable_character_party_ui_instance.ready

	blackboard.remove_value("viewing_character_details")
	blackboard.remove_value("details_requested_for_internal_name")
	blackboard.remove_value("playable_character_party_stage_instance")
	blackboard.remove_value("playable_character_party_ui_instance")

	return true

func _setup_stage(parent: Node3D, position: Vector3):
	_playable_character_party_stage_instance = PLAYABLE_CHARACTER_PARTY_STAGE_SCENE.instantiate()
	parent.add_child(_playable_character_party_stage_instance)
	_playable_character_party_stage_instance.global_position = position
func _save_stage(parent: Node3D):
	# go in and return all world ui objects to their original parents.
	for i in range(_playable_character_party_stage_instance.nonplayable_characters.size()):
		var nonplayable_character = _playable_character_party_stage_instance.nonplayable_characters[i]
		var world_ui_object_manager = nonplayable_character.get_node("%WorldUIObjectManager")
		world_ui_object_manager.return_all()
	parent.remove_child(_playable_character_party_stage_instance)
	get_parent().blackboard.set_value("playable_character_party_stage_instance", _playable_character_party_stage_instance)

func _setup_ui():
	_playable_character_party_ui_instance = PLAYABLE_CHARACTER_PARTY_UI_SCENE.instantiate()
	GameManager.get_instance().get_ui_render_handler().set_ui_scene(_playable_character_party_ui_instance)
func _save_ui():
	get_parent().blackboard.set_value("playable_character_party_ui_instance", _playable_character_party_ui_instance)

func _set_current_camera():
	var camera = _playable_character_party_stage_instance.camera
	GameManager.get_instance().get_world_render_handler().set_current_camera(camera)

func _save_current_party():
	_saved_party = _playable_character_party_manager.current_party

func _setup_nonplayable_characters():
	# go in and connect signals from the nonplayable characters to here
	for i in range(_playable_character_party_stage_instance.nonplayable_characters.size()):
		var nonplayable_character = _playable_character_party_stage_instance.nonplayable_characters[i]
		var world_ui_object_manager = nonplayable_character.get_node("%WorldUIObjectManager")

		var add_character_button: AddCharacterButton = world_ui_object_manager.get_objects("AddCharacterButton")[0]
		add_character_button.button_pressed.connect(_on_add_character_button_pressed.bind(i))

		var character_button: CharacterButton = world_ui_object_manager.get_objects("CharacterButton")[0]
		character_button.button_pressed.connect(_on_character_button_pressed.bind(i))

func _on_add_character_button_pressed(index: int):
	_playable_character_party_ui_instance.start_single_character_select(index)
	_playable_character_party_stage_instance.focus_camera_pedestal(index)

	_playable_character_party_ui_instance.character_selection_canceled.connect(_on_character_selection_canceled)
	_playable_character_party_ui_instance.character_selection_confirmed.connect(_on_character_selection_confirmed)
	_playable_character_party_ui_instance.tentative_party_change_requested.connect(_on_tentative_party_change_requested)
func _on_character_button_pressed(index: int):
	_playable_character_party_ui_instance.start_single_character_select(index)
	_playable_character_party_stage_instance.focus_camera_pedestal(index)

	_playable_character_party_ui_instance.character_selection_canceled.connect(_on_character_selection_canceled)
	_playable_character_party_ui_instance.character_selection_confirmed.connect(_on_character_selection_confirmed)
	_playable_character_party_ui_instance.tentative_party_change_requested.connect(_on_tentative_party_change_requested)

func _on_character_details_requested(internal_name: StringName):
	get_parent().blackboard.set_value("viewing_character_details", true)
	get_parent().blackboard.set_value("details_requested_for_internal_name", internal_name)
	get_parent().fire_event(OPEN_PARTY_MEMBER_DETAILS_MENU)

func _on_quick_select_requested():
	_playable_character_party_ui_instance.start_quick_character_select()
	_playable_character_party_stage_instance.focus_quick_select()

	_playable_character_party_ui_instance.character_selection_canceled.connect(_on_character_selection_canceled)
	_playable_character_party_ui_instance.character_selection_confirmed.connect(_on_character_selection_confirmed)
	_playable_character_party_ui_instance.tentative_party_change_requested.connect(_on_tentative_party_change_requested)

func _on_character_selection_canceled():
	_playable_character_party_stage_instance.current_party = _saved_party
	_playable_character_party_ui_instance.current_party = _saved_party

	_playable_character_party_stage_instance.unfocus_camera()
	_playable_character_party_ui_instance.character_selection_canceled.disconnect(_on_character_selection_canceled)
	_playable_character_party_ui_instance.character_selection_confirmed.disconnect(_on_character_selection_confirmed)
	_playable_character_party_ui_instance.tentative_party_change_requested.disconnect(_on_tentative_party_change_requested)

	if _saved_party.is_empty():
		_playable_character_party_ui_instance.disable_deploy()
		return
	_playable_character_party_ui_instance.enable_deploy()

func _on_character_selection_confirmed():
	_saved_party = _tentative_party
	_playable_character_party_stage_instance.current_party = _saved_party
	_playable_character_party_ui_instance.current_party = _saved_party

	_playable_character_party_stage_instance.unfocus_camera()
	_playable_character_party_ui_instance.character_selection_canceled.disconnect(_on_character_selection_canceled)
	_playable_character_party_ui_instance.character_selection_confirmed.disconnect(_on_character_selection_confirmed)
	_playable_character_party_ui_instance.tentative_party_change_requested.disconnect(_on_tentative_party_change_requested)

	if _saved_party.is_empty():
		_playable_character_party_ui_instance.disable_deploy()
		return
	_playable_character_party_ui_instance.enable_deploy()

func _on_tentative_party_change_requested(party: Party):
	_tentative_party = party

func _on_party_deploy_requested():
	if _saved_party.is_empty():
		return

	_playable_character_party_manager.deploy_party(_saved_party)
	get_parent().fire_event(CLOSE_PARTY_MENU_EVENT)

func _on_close_requested():
	get_parent().fire_event(CLOSE_PARTY_MENU_EVENT)

func _handle_transitions() -> bool:
	if Input.is_action_just_pressed("close_menu"):
		get_parent().fire_event(CLOSE_PARTY_MENU_EVENT)
		return true
	
	return false
