@tool
extends FSMState

const INPUT_BLACKBOARD: String = "INPUT"

@onready var _entity_model_container: Node3D = %EntityModelContainer
@onready var _behaviour_tree_blackboard: BHBlackboard = %BehaviourTreeBlackboard

@export var _speed: float = 6.0
@export var _acceleration: float = 15.0

# Executes after the state is entered.
func _on_enter(_actor: Node, _blackboard: BTBlackboard) -> void:
	pass


func _on_update(delta: float, actor: Node, _blackboard: BTBlackboard) -> void:
	actor = actor as Entity
	
	var direction = _handle_direction_input()
	var velocity = _handle_sprinting(actor.velocity, direction, delta)
	
	actor.velocity = velocity
	var horizontal_velocity = Vector2(velocity.x, velocity.z)
	if not horizontal_velocity.is_zero_approx():
		var horizontal_velocity_normalized = horizontal_velocity.normalized()
		_entity_model_container.rotation.y = atan2(horizontal_velocity_normalized.x, horizontal_velocity_normalized.y)


# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: BTBlackboard) -> void:
	pass


# Add custom configuration warnings
# Note: Can be deleted if you don't want to define your own warnings.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array = []

	warnings.append_array(super._get_configuration_warnings())

	# Add your own warnings to the array here

	return warnings

func _handle_direction_input() -> Vector3:
	var input_direction = _behaviour_tree_blackboard.get_value("input_direction", Vector3.ZERO, INPUT_BLACKBOARD)
	return input_direction

func _handle_sprinting(current_velocity: Vector3, direction: Vector3, delta: float) -> Vector3:
	var velocity = current_velocity.move_toward(direction * _speed, _acceleration * delta)
	return velocity
