@tool
extends EntityState

@export var _gravity: float = 9.8
@export var _acceleration: int = 40

# Executes after the state is entered.
func _on_enter(_actor: Node, _blackboard: BTBlackboard) -> void:
	pass

# Executes every _process call, if the state is active.
func _on_update(delta: float, actor: Node, _blackboard: BTBlackboard) -> void:
	actor = actor as Entity
	
	var velocity = _handle_falling(actor.velocity, delta)
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	
	actor.velocity = velocity
	if not horizontal_velocity.is_zero_approx():
		var horizontal_velocity_normalized = horizontal_velocity.normalized()
		_entity_model_container.rotation.y = atan2(horizontal_velocity_normalized.x, horizontal_velocity_normalized.z)


# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: BTBlackboard) -> void:
	pass

func _handle_falling(current_velocity: Vector3, delta: float) -> Vector3:
	var velocity = current_velocity.move_toward(current_velocity + (Vector3.DOWN * _gravity), _acceleration * delta)
	return velocity
