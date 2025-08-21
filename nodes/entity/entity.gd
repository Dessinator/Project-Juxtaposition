class_name Entity
extends CharacterBody3D

const INPUT_BLACKBOARD: String = "INPUT"
const TIMEOUT_BLACKBOARD: String = "TIMEOUT"

enum EntityType
{
	TYPE_KILOBYTE,
	TYPE_MEGABYTE,
	TYPE_GIGABYTE,
	TYPE_TERABYTE
}

@onready var _navigation_agent_3d: NavigationAgent3D = %NavigationAgent3D
@onready var _entity_visual_controller: Node = %EntityVisualController
@onready var _entity_model_container: Node3D = %EntityModelContainer

@onready var _entity_home_range: EntityRange = %EntityHomeRange
@onready var _entity_wander_range: EntityRange = %EntityWanderRange
@onready var _entity_detection_range: EntityRange = %EntityDetectionRange
@onready var _entity_follow_range: EntityRange = %EntityFollowRange
@onready var _entity_attack_range: EntityRange = %EntityAttackRange

@onready var _state_machine_blackboard: BTBlackboard = %StateMachine.blackboard
@onready var _state_machine: FiniteStateMachine = %StateMachine
@onready var _behaviour_tree_blackboard: BHBlackboard = %BehaviourTreeBlackboard
@onready var _behaviour_tree: BeehaveTree = %BehaviourTree

var player: PlayableCharacter

@export var _entity_type: EntityType = EntityType.TYPE_KILOBYTE

func _ready():
	initialize()

func initialize():
	_cache_player_reference()
	_setup_navigation_agent_3d()
	_setup_ranges()
	_setup_timeouts()
	_start_state_machine()
	_start_behaviour_tree()

func _process(delta: float) -> void:
	pass
	#print(_behaviour_tree_blackboard.get_value("input_direction", Vector3.ZERO, INPUT_BLACKBOARD))

func _physics_process(delta: float) -> void:
	move_and_slide()

func _cache_player_reference():
	player = GameManager.get_instance().get_playable_character()

func _start_state_machine():
	_state_machine.start()
func _start_behaviour_tree():
	_behaviour_tree.enable()
	
func _setup_navigation_agent_3d():
	_navigation_agent_3d.target_position = global_position

func _setup_ranges():
	_entity_home_range.player_entered.connect(_on_entity_home_range_player_entered)
	_entity_home_range.player_exited.connect(_on_entity_home_range_player_exited)
	_entity_wander_range.player_entered.connect(_on_entity_wander_range_player_entered)
	_entity_wander_range.player_exited.connect(_on_entity_wander_range_player_exited)
	_entity_detection_range.player_entered.connect(_on_entity_detection_range_player_entered)
	_entity_detection_range.player_exited.connect(_on_entity_detection_range_player_exited)
	_entity_follow_range.player_entered.connect(_on_entity_follow_range_player_entered)
	_entity_follow_range.player_exited.connect(_on_entity_follow_range_player_exited)
	_entity_attack_range.player_entered.connect(_on_entity_attack_range_player_entered)
	_entity_attack_range.player_exited.connect(_on_entity_attack_range_player_exited)

func _on_entity_home_range_player_entered(_player: PlayableCharacter):
	_behaviour_tree_blackboard.set_value("is_player_in_home_range", true)
func _on_entity_home_range_player_exited(_player: PlayableCharacter):
	_behaviour_tree_blackboard.set_value("is_player_in_home_range", false)
func _on_entity_wander_range_player_entered(_player: PlayableCharacter):
	_behaviour_tree_blackboard.set_value("is_player_in_wander_range", true)
func _on_entity_wander_range_player_exited(_player: PlayableCharacter):
	_behaviour_tree_blackboard.set_value("is_player_in_wander_range", false)
func _on_entity_detection_range_player_entered(_player: PlayableCharacter):
	_behaviour_tree_blackboard.set_value("is_player_in_detection_range", true)
	_behaviour_tree.interrupt()
func _on_entity_detection_range_player_exited(_player: PlayableCharacter):
	_behaviour_tree_blackboard.set_value("is_player_in_detection_range", false)
	_behaviour_tree.interrupt()
func _on_entity_follow_range_player_entered(_player: PlayableCharacter):
	_behaviour_tree_blackboard.set_value("is_player_in_follow_range", true)
	_behaviour_tree.interrupt()
func _on_entity_follow_range_player_exited(_player: PlayableCharacter):
	_behaviour_tree_blackboard.set_value("is_player_in_follow_range", false)
	_behaviour_tree.interrupt()
func _on_entity_attack_range_player_entered(_player: PlayableCharacter):
	_behaviour_tree_blackboard.set_value("is_player_in_attack_range", true)
	_behaviour_tree.interrupt()
func _on_entity_attack_range_player_exited(_player: PlayableCharacter):
	_behaviour_tree_blackboard.set_value("is_player_in_attack_range", false)
	#_behaviour_tree.interrupt()


func _setup_timeouts():
	pass
