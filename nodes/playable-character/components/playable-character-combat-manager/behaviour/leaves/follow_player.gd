extends ActionLeaf

@export var _time: float = 0.1

func tick(actor: Node, blackboard: BHBlackboard) -> int:
	actor = actor as PlayableCharacterCombatManager
	
	var playable_character = actor.playable_character
	var camera = actor.camera
	var position = playable_character.global_position
	
	camera.enable_input = true
	camera.enable_camera_follow = true
	camera.enable_camera_zoom = true
	camera.enable_camera_tilt = true
	camera.enable_camera_horizontal_rotation = true
	
	var tween = create_tween()
	tween.tween_property(camera, "global_position", position, _time)
	
	return SUCCESS
