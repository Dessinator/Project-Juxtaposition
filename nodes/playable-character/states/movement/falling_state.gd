@tool
extends PlayableCharacterGameplayState

@export var _gravity: float = 9.8
@export var _acceleration: int = 40

func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	super(actor, blackboard)
	_playable_character_mover.use_root_motion = false

func _on_update(delta: float, actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	
	var velocity = _handle_falling(actor.velocity, delta)
	_playable_character_mover.set_velocity(velocity)

# Executes before the state is exited.
func _on_exit(actor: Node, blackboard: BTBlackboard) -> void:
	super(actor, blackboard)
	_playable_character_mover.use_root_motion = true

func _handle_falling(current_velocity: Vector3, delta: float) -> Vector3:
	var velocity = current_velocity.move_toward(current_velocity + (Vector3.DOWN * _gravity), _acceleration * delta)
	return velocity
