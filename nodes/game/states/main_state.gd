@tool
extends FSMState

func _on_enter(actor: Node, _blackboard: BTBlackboard) -> void:
	actor = actor as GameManager
	
	var playable_character = actor.get_playable_character()
	playable_character.initialize(actor)

func _on_update(_delta: float, _actor: Node, _blackboard: BTBlackboard) -> void:
	pass

func _on_exit(_actor: Node, _blackboard: BTBlackboard) -> void:
	pass
