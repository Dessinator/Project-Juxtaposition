class_name StatusInterface
extends Node

var _status: Status

@export var _max_health: int = 5

@export var _damage_resistance: float = 0.00
@export var _debuff_resistance: float = 0.00
@export var _buff_retention: float = 0.00

func _ready() -> void:
	_status = Status.new()
	
	_status._max_health = _max_health
	_status._health = _max_health
	_status._damage_resistance = _damage_resistance
	_status._debuff_resistance = _debuff_resistance
	_status._buff_retention = _buff_retention

func get_status() -> Status:
	return _status
