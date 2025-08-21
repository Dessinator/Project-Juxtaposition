extends ActionLeaf

func tick(actor: Node, blackboard: BHBlackboard):
	actor = actor as Entity
	
	var player_global_position = actor.player.global_position
	blackboard.set_value("target_position", player_global_position)
	
	return SUCCESS
