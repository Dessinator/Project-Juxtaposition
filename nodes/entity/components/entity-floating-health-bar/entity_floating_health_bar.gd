@tool
class_name EntityFloatingHealthBar
extends Node3D

var _world_origin: Marker3D

@export var _length: int = 200:
	set(value):
		if value < 0:
			return
		
		_length = value
		%SubViewport.size.x = _length

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
