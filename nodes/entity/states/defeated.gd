@tool
extends EntityState

const ENTITY_DEATH_POOF_PARTICLES_SCENE = preload("res://nodes/particles/entity/entity_death_poof_particles.tscn")

# Executes after the state is entered.
func _on_enter(actor: Node, _blackboard: BTBlackboard) -> void:
	actor = actor as Entity
	
	_entity_model_container.visible = false
	var instance = ENTITY_DEATH_POOF_PARTICLES_SCENE.instantiate()
	actor.add_child(instance)
	await get_tree().create_timer(1).timeout
	
	actor.queue_free()

# Executes every _process call, if the state is active.
func _on_update(_delta: float, _actor: Node, _blackboard: BTBlackboard) -> void:
	pass

# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: BTBlackboard) -> void:
	pass
