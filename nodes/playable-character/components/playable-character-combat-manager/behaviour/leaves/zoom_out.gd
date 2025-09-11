extends ActionLeaf

func tick(actor: Node, blackboard: BHBlackboard) -> int:
	actor = actor as PlayableCharacterCombatManager
	
	var playable_character = actor.playable_character
	var camera = actor.camera
	var player_position = playable_character.global_position
	var targets = actor.target_range.targets_in_range
	
	camera.enable_camera_zoom = true
	
	var tween = create_tween()
	tween.tween_property(camera, "zoom", camera.min_zoom, 0.5)
	
	return SUCCESS
