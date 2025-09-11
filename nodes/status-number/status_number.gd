@tool
class_name StatusNumber
extends Node3D

const LABEL_PLACEHOLDER_TEXT: String = "PRE???SUF"

@onready var _label_3d: Label3D = %Label3D

var _world_origin: Marker3D

@export var prefix: String:
	set(value):
		prefix = value
		_update_label()
@export var suffix: String:
	set(value):
		suffix = value
		_update_label()
@export var value: int = -1:
	set(v):
		value = v
		_update_label()

func _ready() -> void:
	_update_label()
	
	global_position = get_parent().global_position
	
	var velocity = Vector3(randf_range(-1.5, 1.5), randf_range(-1.5, 1.5), randf_range(-1.5, 1.5))
	create_tween().tween_property(self, "position", position + velocity, 2)
	
	_create_world_origin()

func _process(delta: float) -> void:
	pass
	#_copy_world_origin_position_and_rotation()

func _update_label():
	if prefix.is_empty() and suffix.is_empty() and value == -1:
		%Label3D.text = LABEL_PLACEHOLDER_TEXT
		return
	
	var string = prefix + str(value) + suffix
	%Label3D.text = string

func _create_world_origin():
	_world_origin = Marker3D.new()
	_world_origin.name = name + str(get_instance_id())
	_world_origin.global_position = global_position
	
	var parent = get_parent()
	var world_ui_sub_viewport = await GameManager.get_world_ui_sub_viewport()
	
	parent.add_child(_world_origin)
	
	reparent(world_ui_sub_viewport, true)
func _copy_world_origin_position_and_rotation():
	global_position = _world_origin.global_position
	global_rotation = _world_origin.global_rotation
