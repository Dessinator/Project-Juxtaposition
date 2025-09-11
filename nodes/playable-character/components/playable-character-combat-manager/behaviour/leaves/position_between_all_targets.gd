extends ActionLeaf

@export var _time: float = 0.5

func tick(actor: Node, blackboard: BHBlackboard) -> int:
	actor = actor as PlayableCharacterCombatManager
	
	var playable_character = actor.playable_character
	var camera = actor.camera
	var player_position = playable_character.global_position
	var targets = actor.target_range.targets_in_range
	
	var x_sum = 0
	var y_sum = 0
	var z_sum = 0
	var divisor = 1
	
	# add bias towards the player
	for i in range(6):
		x_sum += player_position.x
		y_sum += player_position.y
		z_sum += player_position.z
		
		divisor += 1
	
	for target in targets:
		x_sum += target.global_position.x
		y_sum += target.global_position.y
		z_sum += target.global_position.z
		
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
