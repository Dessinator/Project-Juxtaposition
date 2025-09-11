extends ActionLeaf

@export var _time: float = 0.5

func tick(actor: Node, blackboard: BHBlackboard) -> int:
	actor = actor as PlayableCharacterCombatManager
	
	var playable_character = actor.playable_character
	var camera = actor.camera
	var player_position = playable_character.global_position
	var target = blackboard.get_value("tracked_target_position")
	
	var x_sum = target.x
	var y_sum = target.y
	var z_sum = target.z
	var divisor = 1
	
	# add bias towards the player
	for i in range(3):
		x_sum += player_position.x
		y_sum += player_position.y
		z_sum += player_position.z
		
		divisor += 1
	
	x_sum /= divisor
	y_sum /= divisor
	z_sum /= divisor

	var average_position = Vector3(x_sum, y_sum, z_sum);
	
	camera.enable_input = true
	camera.enable_camera_follow = true
	camera.enable_camera_zoom = true
	camera.enable_camera_tilt = true
	camera.enable_camera_horizontal_rotation = true
	
	var tween = create_tween()
	tween.tween_property(camera, "global_position", average_position, _time)
	
	return SUCCESS
