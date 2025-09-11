extends ActionLeaf

@export var _track_speed: float = 15.0

func tick(actor: Node, blackboard: BHBlackboard) -> int:
	actor = actor as PlayableCharacterCombatManager
	
	var playable_character = actor.playable_character
	var camera = actor.camera
	var position = playable_character.global_position
	var camera_node: Camera3D = camera.get_camera()
	
	camera.enable_input = false
	camera.enable_camera_follow = false
	camera.enable_camera_zoom = false
	camera.enable_camera_tilt = false
	camera.enable_camera_horizontal_rotation = false
	
	var looking_at = camera_node.global_transform.looking_at(position).basis
	var looking_at_rotation = looking_at.get_rotation_quaternion()

	var tween = get_tree().create_tween()

	camera_node.quaternion = camera_node.quaternion.slerp(looking_at_rotation, get_process_delta_time() * _track_speed)
	tween.tween_property(camera, "global_position", position, 0.1)
	tween.tween_property(camera._camera_rotation_pivot, "global_rotation:y", camera_node.global_rotation.y, 0.1)
	
	return SUCCESS
