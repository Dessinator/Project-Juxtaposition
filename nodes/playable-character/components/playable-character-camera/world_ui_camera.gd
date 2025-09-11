extends Camera3D

var _world_origin: Marker3D

func _ready() -> void:
	_create_world_origin()

func _process(delta: float) -> void:
	_copy_world_origin_position_and_rotation()

func _create_world_origin():
	_world_origin = Marker3D.new()
	_world_origin.name = name + str(get_instance_id())
	#_world_origin.global_position = global_position
	
	var parent = get_parent()
	var world_ui_sub_viewport = await GameManager.get_world_ui_sub_viewport()
	
	parent.add_child(_world_origin)
	
	reparent(world_ui_sub_viewport, true)
func _copy_world_origin_position_and_rotation():
	global_position = _world_origin.global_position
	global_rotation = _world_origin.global_rotation
