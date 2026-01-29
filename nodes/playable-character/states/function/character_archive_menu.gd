@tool
extends FSMState

const PLAYABLE_CHARACTER_CHARACTER_STAGE_SCENE: PackedScene = preload("res://nodes/playable-character/components/playable-character-character-stage/playable_character_character_stage.tscn")
const PLAYABLE_CHARACTER_CHARACTER_ARCHIVE_UI_SCENE: PackedScene = preload("res://nodes/playable-character/components/playable-character-character-archive-ui/playable_character_character_archive_ui.tscn")

const CLOSE_CHARACTER_ARCHIVE_MENU_EVENT: String = "close_character_archive_menu"

@onready var _gameplay_finite_state_machine: FiniteStateMachine = %GameplayFiniteStateMachine
@onready var _idle_state: PlayableCharacterGameplayState = %IdleState
@onready var _animation_finite_state_machine: FiniteStateMachine = %AnimationFiniteStateMachine

var _playable_character_character_stage_instance: PlayableCharacterCharacterStage
var _playable_character_character_archive_ui_instance: PlayableCharacterCharacterArchiveUI

# Executes after the state is entered.
func _on_enter(actor: Node, _blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	actor.velocity = Vector3.ZERO
	actor.visible = false

	_set_gameplay_state_machine_active(false)
	_set_animation_state_machine_active(false)
	
	_set_environment_visible(false)
	_setup_stage(actor.get_parent(), actor.global_position)
	# await the stage ready signal
	if not _playable_character_character_stage_instance.is_node_ready():
		await _playable_character_character_stage_instance.ready
	_setup_ui()
	# await the ui ready signal
	if not _playable_character_character_archive_ui_instance.is_node_ready():
		await _playable_character_character_archive_ui_instance.ready

	_set_current_camera()

	var character_internal_name = Characters.get_all_character_packets()[0].character_data.internal_name

	_set_character_internal_name(character_internal_name)

	_playable_character_character_archive_ui_instance.character_change_requested.connect(_on_character_change_requested)
	_playable_character_character_archive_ui_instance.close_requested.connect(_on_close_requested)


# Executes every _process call, if the state is active.
func _on_update(_delta: float, _actor: Node, _blackboard: BTBlackboard) -> void:
	pass


# Executes before the state is exited.
func _on_exit(actor: Node, _blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	
	actor.visible = true

	_set_gameplay_state_machine_active(true)
	_set_animation_state_machine_active(true)

	_set_environment_visible(true)

	# free the stage
	_playable_character_character_stage_instance.queue_free()


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

func _setup_stage(parent: Node3D, position: Vector3):
	_playable_character_character_stage_instance = PLAYABLE_CHARACTER_CHARACTER_STAGE_SCENE.instantiate()
	parent.add_child(_playable_character_character_stage_instance)
	_playable_character_character_stage_instance.global_position = position

func _setup_ui():
	_playable_character_character_archive_ui_instance = PLAYABLE_CHARACTER_CHARACTER_ARCHIVE_UI_SCENE.instantiate()
	GameManager.get_instance().get_ui_render_handler().set_ui_scene(_playable_character_character_archive_ui_instance)

func _set_current_camera():
	var camera = _playable_character_character_stage_instance.get_node("%TrackballCamera")
	GameManager.get_instance().get_world_render_handler().set_current_camera(camera)

func _set_character_internal_name(internal_name: StringName):
	_playable_character_character_stage_instance.current_character_internal_name = internal_name
	_playable_character_character_archive_ui_instance.current_character_internal_name = internal_name

func _on_character_change_requested(internal_name: StringName):
	_set_character_internal_name(internal_name)

func _on_close_requested():
	get_parent().fire_event(CLOSE_CHARACTER_ARCHIVE_MENU_EVENT)

func _handle_transitions() -> bool:
	if Input.is_action_just_pressed("close_menu"):
		get_parent().fire_event(CLOSE_CHARACTER_ARCHIVE_MENU_EVENT)
		return true
	
	return false
