class_name AttackInstance
extends Resource

var _damage: int
var _status_effect: StatusEffect

func _init(damage: int, status_effect: StatusEffect) -> void:
	_damage = damage
	_status_effect = status_effect

func get_damage() -> int:
	return _damage
func get_status_effect() -> StatusEffect:
	return _status_effect

func set_damage(value: int) -> void:
	_damage = value
func set_status_effect(status_effect: StatusEffect) -> void:
	_status_effect = status_effect
