@tool
extends PlayableCharacterGameplayState

const PLAYABLE_CHARACTER_DEATH_POOF_PARTICLES_SCENE = preload("res://nodes/particles/playable-character/playable_character_death_poof_particles.tscn")

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	super(actor, blackboard)
	actor = actor as PlayableCharacter
	
	actor.velocity = Vector3.ZERO
	
	var character_container = actor.get_playable_character_character_container()
	var character = character_container.get_current_character()
	var animation_tree = character.get_node("%AnimationTree") as AnimationTree
	
	var animation = await animation_tree.animation_finished
	
	var instance = PLAYABLE_CHARACTER_DEATH_POOF_PARTICLES_SCENE.instantiate()
	actor.add_child(instance)
	
	if character_container.all_characters_dead():
		return
	
	get_parent().fire_event("on_start_replace")

# Executes every _process call, if the state is active.
func _on_update(_delta: float, _actor: Node, _blackboard: BTBlackboard) -> void:
	pass

# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: BTBlackboard) -> void:
	pass
