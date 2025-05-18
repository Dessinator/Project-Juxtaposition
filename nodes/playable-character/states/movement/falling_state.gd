@tool
extends FSMState

@export var _gravity: float = 9.8
@export var _acceleration: int = 40

@export var _character: Character

@onready var _animation_finite_state_machine: FiniteStateMachine = %AnimationFiniteStateMachine
@onready var _fall_animation_state: Node = %FallAnimationState

@onready var _stamina_regeneration_delay_timer: Timer = %StaminaRegenerationDelayTimer

func _on_enter(_actor: Node, blackboard: BTBlackboard) -> void:
	_animation_finite_state_machine.change_state(_fall_animation_state)
	
	_stamina_regeneration_delay_timer.stop()
	blackboard.set_value("regenerate_stamina", false)

func _on_update(delta: float, actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	
	var velocity = _handle_falling(actor.velocity, delta)
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	
	actor.velocity = velocity
	if not horizontal_velocity.is_zero_approx():
		var horizontal_velocity_normalized = horizontal_velocity.normalized()
		_character.rotation.y = atan2(horizontal_velocity_normalized.x, horizontal_velocity_normalized.z)

# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: BTBlackboard) -> void:
	pass

func _handle_falling(current_velocity: Vector3, delta: float) -> Vector3:
	var velocity = current_velocity.move_toward(current_velocity + (Vector3.DOWN * _gravity), _acceleration * delta)
	return velocity
