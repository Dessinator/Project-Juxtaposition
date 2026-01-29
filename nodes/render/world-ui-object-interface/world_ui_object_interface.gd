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
@export var _self_initialize: bool = true

func _ready() -> void:
	if not _self_initialize:
		return
	
	initialize()

func initialize():
	_create_world_origin()

	# _world_origin.tree_exiting.connect(_handle_self_return)

func _process(delta: float) -> void:
	_handle_self_destruct()
	_copy_world_origin_position_and_rotation()

func _create_world_origin():
	var parent = get_parent()
	if not parent.is_node_ready():
		await parent.ready

	var grandparent = parent.get_parent()
	var world_ui_sub_viewport = await GameManager.get_world_ui_sub_viewport()
	
	_world_origin = Marker3D.new()
	_world_origin.name = parent.name + " World Origin " + str(get_instance_id())
	
	match _world_origin_initial_position_copy_type:
		WorldOriginInitialPositionCopyType.GLOBAL_POSITION:
			_world_origin.global_position = parent.global_position
		WorldOriginInitialPositionCopyType.LOCAL_POSITION:
			_world_origin.position = parent.position
	
	await grandparent.ready

	grandparent.add_child(_world_origin)
	parent.reparent(world_ui_sub_viewport, true)

	_world_origin.visibility_changed.connect(_on_world_origin_visibility_changed)

func handle_return():
	var parent = get_parent()
	var origin_parent = _world_origin.get_parent()
	parent.reparent(origin_parent)
	_world_origin.queue_free()
	request_ready()

func _handle_self_destruct():
	if not _world_origin == null:
		return
	
	get_parent().queue_free()

func _copy_world_origin_position_and_rotation():
	if _world_origin == null:
		return
	if not _world_origin.is_inside_tree():
		return
	
	var parent = get_parent()
	
	parent.global_position = _world_origin.global_position
	parent.global_rotation = _world_origin.global_rotation

func _on_world_origin_visibility_changed():
	get_parent().visible = _world_origin.is_visible_in_tree()
