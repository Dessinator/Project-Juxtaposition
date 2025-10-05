@tool
extends PlayableCharacterGameplayState

const LAUNCH_FORCE_VECTOR_STRING: String = "launch_force_vector"

@export var _gravity: float = 9.8
@export var _acceleration: float = 40.0

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	
	var launch_force_vector = blackboard.get_value(LAUNCH_FORCE_VECTOR_STRING)
	actor.velocity = launch_force_vector

# Executes every _process call, if the state is active.
func _on_update(delta: float, actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	
	var velocity = _handle_launch(actor.velocity, delta)
	if velocity.y < 0:
		get_parent().fire_event(ON_START_AIRBORNE)
		return
	
	actor.velocity = velocity

# Executes before the state is exited.
func _on_exit(actor: Node, blackboard: BTBlackboard) -> void:
	super(actor, blackboard)

func _handle_launch(current_velocity: Vector3, delta: float) -> Vector3:
	var velocity = current_velocity.move_toward(Vector3.DOWN * _gravity, _acceleration * delta)
	
	return velocity
