@tool
extends FSMState
class_name EntityState

const ON_START_IDLING: String = "on_start_idling"
const ON_START_WALKING: String = "on_start_walking"
const ON_START_SPRINTING: String = "on_start_sprinting"
const ON_START_GROUNDED_ATTACKING: String = "on_start_grounded_attacking"
const ON_START_GROUNDED_DAMAGED: String = "on_start_grounded_damaged"
const ON_START_JUMPING: String = "on_start_jumping"
const ON_START_FALLING: String = "on_start_falling"
const ON_START_LANDING: String = "on_start_landing"
const ON_START_LAUNCHED: String = "on_start_launched"
const ON_START_AIRBORNE: String = "on_start_airborne"
const ON_START_ARIAL_ATTACKING: String = "on_start_arial_attacking"
const ON_START_ARIAL_DAMAGED: String = "on_start_arial_damaged"
const ON_START_SPIKED: String = "on_start_spiked"
const ON_START_DEFEATED: String = "on_start_defeated"

@onready var _entity_model_container: Node3D = %EntityModelContainer
@onready var _behaviour_tree_blackboard: BHBlackboard = %BehaviourTreeBlackboard

# Executes after the state is entered.
func _on_enter(_actor: Node, _blackboard: BTBlackboard) -> void:
	pass


# Executes every _process call, if the state is active.
func _on_update(_delta: float, _actor: Node, _blackboard: BTBlackboard) -> void:
	pass


# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: BTBlackboard) -> void:
	pass
