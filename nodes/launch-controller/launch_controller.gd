class_name LaunchController
extends Node

const LAUNCH_FORCE_VECTOR_STRING: String = "launch_force_vector"
const SPIKE_FORCE_VECTOR_STRING: String = "spike_force_vector"
const LAUNCHED_EVENT: String = "on_launched"
const SPIKED_EVENT: String = "on_spiked"

@onready var _body: PhysicsBody3D

@export var _launch_force: float
@export var _spike_force: float
@export var _state_machine: FiniteStateMachine

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func launch():
	var launch_force_vector = handle_launch_force()
	
	_handle_update_state_machine(LAUNCH_FORCE_VECTOR_STRING, launch_force_vector, LAUNCHED_EVENT)
	
	# TODO: implement with rigidbodies/non FSM controlled objects
func spike():
	var spike_force_vector = handle_spike_force()
	
	_handle_update_state_machine(SPIKE_FORCE_VECTOR_STRING, spike_force_vector, SPIKED_EVENT)
	
	# TODO: implement with rigidbodies/non FSM controlled objects

func handle_launch_force() -> Vector3:
	var velocity = Vector3(0, _launch_force, 0)
	return velocity
func handle_spike_force() -> Vector3:
	var velocity = Vector3(0, -_spike_force, 0)
	return velocity

func _handle_update_state_machine(key: String, force_vector: Vector3, event_name: String):
	if not _state_machine:
		return
	
	_state_machine.blackboard.set_value(key, force_vector)
	_state_machine.fire_event(event_name)
