class_name Substat
extends Resource

@export var _internal_name: StringName
@export var _readable_name: String
@export var _readable_abbreviation: String
@export var _curve: Curve

var _constant: float
var _constant_modifiers: Dictionary = {}

func sample(input: float, base_value: bool):
	var sampled = _curve.sample(input)
	if not base_value:
		sampled += _constant
	
	return sampled

func add_constant_modifier(modification: float) -> int:
	var id = randi()
	_constant_modifiers.set(id, modification)
	
	_update_constant_value()
	return id
func remove_constant_modifier(id: int):
	assert(_constant_modifiers.has(id),
		"Substat {readable_name} (internal_name) does not have a constant modifier by id {modifier_id}".format({
			"readable_name" : _readable_name,
			"internal_name" : _internal_name,
			"modifier_id" : id
		}))
	
	_constant_modifiers.erase(id)
	
	_update_constant_value()

func get_internal_name() -> StringName:
	return _internal_name
func get_readable_name() -> String:
	return _readable_name
func get_readable_abbreviation() -> String:
	return _readable_abbreviation

func get_constant() -> float:
	return _constant

func _update_constant_value():
	var constant = 0.0
	
	for id in _constant_modifiers.keys():
		var modification = _constant_modifiers[id]
		
		constant += modification
	
	_constant = constant
