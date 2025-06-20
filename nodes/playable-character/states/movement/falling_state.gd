@tool
extends PlayableCharacterGameplayState

@export var _gravity: float = 9.8
@export var _acceleration: int = 40

@onready var _stamina_regeneration_delay_timer: Timer = %StaminaRegenerationDelayTimer

func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	super(actor, blackboard)
	_stamina_regeneration_delay_timer.stop()
	blackboard.set_value("regenerate_stamina", false)

func _on_update(delta: float, actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	
	var velocity = _handle_falling(actor.velocity, delta)
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	
	actor.velocity = velocity
	if not horizontal_velocity.is_zero_approx():
		var horizontal_velocity_normalized = horizontal_velocity.normalized()
		_playable_character_character_container.rotation.y = atan2(horizontal_velocity_normalized.x, horizontal_velocity_normalized.z)

# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: BTBlackboard) -> void:
	pass

func _handle_falling(current_velocity: Vector3, delta: float) -> Vector3:
	var velocity = current_velocity.move_toward(current_velocity + (Vector3.DOWN * _gravity), _acceleration * delta)
	return velocity
