@tool
extends EntityState

@onready var _airborne_timer: Timer = %AirborneTimer
@onready var _damage_taken_timer: Timer = %DamageTakenTimer

@export var _gravity: float
@export var _acceleration: int = 40
@export var _boost_force: float

# Executes after the state is entered.
func _on_enter(actor: Node, _blackboard: BTBlackboard) -> void:
	actor = actor as Entity
	
	_handle_starting_airborne_timer()
	actor.velocity += Vector3.UP * _boost_force
	
	_damage_taken_timer.timeout.connect(_on_damage_taken_timer_timeout)
	_damage_taken_timer.start()

# Executes every _process call, if the state is active.
func _on_update(delta: float, actor: Node, _blackboard: BTBlackboard) -> void:
	actor = actor as Entity
	
	var velocity = _handle_falling(actor.velocity, delta)
	actor.velocity = velocity

# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: BTBlackboard) -> void:
	_airborne_timer.timeout.disconnect(_on_airborne_timer_timeout)

func _handle_starting_airborne_timer():
	_airborne_timer.timeout.connect(_on_airborne_timer_timeout)
	if not _airborne_timer.is_stopped():
		var new_time = _airborne_timer.time_left + 1.5
		if new_time > _airborne_timer.wait_time:
			new_time = _airborne_timer.wait_time
		_airborne_timer.start(new_time)
		return
	_airborne_timer.start()

func _handle_falling(current_velocity: Vector3, delta: float) -> Vector3:
	var velocity = current_velocity.move_toward(Vector3.DOWN * _gravity, _acceleration * delta)
	return velocity

func _on_airborne_timer_timeout():
	pass

func _on_damage_taken_timer_timeout():
	_handle_transitions()
	
func _handle_transitions():
	get_parent().fire_event(ON_START_AIRBORNE)
