class_name WorldUIObjectInterface
extends Node

enum WorldOriginInitialPositionCopyType
{
	RESET,
	GLOBAL_POSITION,
	LOCAL_POSITION
}

var _world_origin: Marker3D

@export var _world_origin_initial_position_copy_type: WorldOriginInitialPositionCopyType = WorldOriginInitialPositionCopyType.RESET

func _ready() -> void:
	_create_world_origin()

func _process(delta: float) -> void:
	_copy_world_origin_position_and_rotation()

func _create_world_origin():
	var parent = get_parent()
	var grandparent = parent.get_parent()
	var world_ui_sub_viewport = await GameManager.get_world_ui_sub_viewport()
	
	_world_origin = Marker3D.new()
	_world_origin.name = parent.name + " World Origin " + str(get_instance_id())
	
	match _world_origin_initial_position_copy_type:
		WorldOriginInitialPositionCopyType.GLOBAL_POSITION:
			_world_origin.global_position = parent.global_position
		WorldOriginInitialPositionCopyType.LOCAL_POSITION:
			_world_origin.position = parent.position
	
	grandparent.add_child(_world_origin)
	
	parent.reparent(world_ui_sub_viewport, true)

func _copy_world_origin_position_and_rotation():
	var parent = get_parent()
	
	parent.global_position = _world_origin.global_position
	parent.global_rotation = _world_origin.global_rotation
