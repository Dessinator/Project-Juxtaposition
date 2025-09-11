@tool
class_name EntityRange
extends Area3D

signal player_entered(player: PlayableCharacter)
signal player_exited(player: PlayableCharacter)

@onready var _collision_shape_3d: CollisionShape3D = %CollisionShape3D
@onready var _current_range: float = range

var is_player_in_range: bool = false

@export var _is_static: bool = false:
	set(value):
		_is_static = value
		_editor_update()
@export var range: float = 3.0:
	set(value):
		range = value
		if max_range < range:
			max_range = range
		
		_editor_update()
@export var max_range: float = 3.0:
	set(value):
		if value < range:
			return
		max_range = value

@export var _disabled: bool:
	set(value):
		_disabled = value
		_editor_update()
@export var _debug_color: Color = Color(1, 0, 0, 0.5):
	set(value):
		_debug_color = value
		_editor_update()
@export var _debug_fill: bool = true:
	set(value):
		_debug_fill = value
		_editor_update()

func _ready() -> void:
	if Engine.is_editor_hint():
		_editor_update()
	
	if _is_static:
		global_position = get_parent().global_position
	
	top_level = _is_static

	_collision_shape_3d.shape.radius = range
	_collision_shape_3d.disabled = _disabled
	_collision_shape_3d.debug_color = _debug_color
	_collision_shape_3d.debug_fill = _debug_fill

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		if _is_static:
			global_position = get_parent().global_position

func _editor_update():
	if not Engine.is_editor_hint():
		return
	
	top_level = _is_static

	_collision_shape_3d.shape.radius = range
	_collision_shape_3d.disabled = _disabled
	_collision_shape_3d.debug_color = _debug_color
	_collision_shape_3d.debug_fill = _debug_fill

func set_current_range(value: float):
	_current_range = value
	if _current_range > max_range:
		_current_range = max_range
	if _current_range < 0:
		_current_range = 0
	
	_collision_shape_3d.shape.radius = _current_range
func get_current_range() -> float:
	return _current_range

# for now, EntityRange only monitors Layer 3 (PlayerLayer). whenever a body enters
# or exits this body, it will be the player.
func _on_body_entered(body: Node3D) -> void:
	if not body is PlayableCharacter:
		# should never be the case
		return
	
	body = body as PlayableCharacter
	player_entered.emit(body)
	is_player_in_range = true
func _on_body_exited(body: Node3D) -> void:
	if not body is PlayableCharacter:
		# should never be the case
		return
	
	body = body as PlayableCharacter
	player_exited.emit(body)
	is_player_in_range = false
