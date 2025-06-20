@tool
extends PlayableCharacterGameplayState

const PLAYABLE_CHARACTER_LANDING_PARTICLES_SCENE = preload("res://nodes/particles/playable-character/playable_character_landing_particles.tscn")

func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	super(actor, blackboard)
	actor = actor as PlayableCharacter
	
	var landing_particles = PLAYABLE_CHARACTER_LANDING_PARTICLES_SCENE.instantiate()
	actor.add_child(landing_particles)
	
	actor.velocity.y = 0
	if not Input.is_action_pressed("move"):
		actor.velocity = Vector3.ZERO

func _on_update(_delta: float, _actor: Node, _blackboard: BTBlackboard) -> void:
	pass

func _on_exit(_actor: Node, _blackboard: BTBlackboard) -> void:
	pass
