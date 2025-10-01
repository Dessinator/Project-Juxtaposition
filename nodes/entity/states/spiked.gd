@tool
extends EntityState

const SPIKE_BURST_PARTICLES_SCENE = preload("res://nodes/particles/combat/spike_burst_particles.tscn")

const SPIKE_FORCE_VECTOR_STRING: String = "spike_force_vector"
const ACCUMULATED_SPIKE_DAMAGE_STRING: String = "accumulated_spike_damage"

@onready var _status_interface: StatusInterface = %StatusInterface
@onready var _spike_trail_particles: Node3D = %SpikeTrailParticles

var starting_spike_height: int

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as Entity
	
	starting_spike_height = int(actor.global_position.y)
	blackboard.set_value(ACCUMULATED_SPIKE_DAMAGE_STRING, 0)
	var spike_force_vector = blackboard.get_value(SPIKE_FORCE_VECTOR_STRING)
	actor.velocity = spike_force_vector
	
	var burst_instance = SPIKE_BURST_PARTICLES_SCENE.instantiate()
	actor.add_child(burst_instance)
	
	var particle_systems = _spike_trail_particles.get_children()
	for particle_system in particle_systems:
		particle_system.emitting = true

# Executes every _process call, if the state is active.
func _on_update(_delta: float, actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as Entity
	
	blackboard.set_value(ACCUMULATED_SPIKE_DAMAGE_STRING, _handle_accumulated_spike_damage(int(actor.global_position.y), blackboard.get_value("accumulated_spike_damage")))

# Executes before the state is exited.
func _on_exit(actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as Entity
	
	var particle_systems = _spike_trail_particles.get_children()
	for particle_system in particle_systems:
		particle_system.emitting = false
	
	var status = _status_interface.get_status()
	var damage_instance = DamageInstance.new(actor, blackboard.get_value(ACCUMULATED_SPIKE_DAMAGE_STRING))
	damage_instance.spawn_damage_number = true
	status.damage(damage_instance)

func _handle_accumulated_spike_damage(current_height: int, current_damage: int) -> int:
	var diff = starting_spike_height - current_height
	var damage = current_damage + diff
	
	return damage
	
