@tool
extends EntityState

@onready var _airborne_timer: Timer = %AirborneTimer

@export var _gravity: float
@export var _acceleration: int = 40

# Executes after the state is entered.
func _on_enter(actor: Node, _blackboard: BTBlackboard) -> void:
	actor = actor as Entity
	
	_airborne_timer.timeout.connect(_on_airborne_timer_timeout)
	_airborne_timer.start()

# Executes every _process call, if the state is active.
func _on_update(delta: float, actor: Node, _blackboard: BTBlackboard) -> void:
	actor = actor as Entity
	
	var velocity = _handle_falling(actor.velocity, delta)
	
	actor.velocity = velocity

# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: BTBlackboard) -> void:
	_airborne_timer.timeout.disconnect(_on_airborne_timer_timeout)

func _handle_falling(current_velocity: Vector3, delta: float) -> Vector3:
	var velocity = current_velocity.move_toward(Vector3.DOWN * _gravity, _acceleration * delta)
	return velocity

func _on_airborne_timer_timeout():
	get_parent().fire_event("on_start_falling")
