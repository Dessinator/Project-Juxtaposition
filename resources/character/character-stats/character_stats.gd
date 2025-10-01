class_name CharacterStats extends Resource

@export var _stats: Array[Stat]
@export var _substats: Array[Substat]
@export var _wards: Array[StatusEffect]
@export var _alignment: Alignment = Alignment.new()

# sampled when damage is dealt to determine how much to add to the juxtometer.
@export var _juxtometer_damage_dealt_curve: Curve = Curve.new()
# sampled when damage is taken to determine how much to subtract from the juxtometer.
@export var _juxtometer_damage_taken_curve: Curve = Curve.new()

var _internal_stats: Dictionary
var _internal_substats: Dictionary

func initialize():
	_duplicate_stat_resources()
	_duplicate_substat_resources()

func get_stat(internal_name: StringName) -> Stat:
	assert(_internal_stats.has(internal_name),
		"CharacterStats resource does not contain a Stat resource with internal name '{internal_name}'".format({
			"internal_name" : internal_name
		}))
	
	return _internal_stats[internal_name]
func get_substat(internal_name: StringName) -> Substat:
	assert(_internal_substats.has(internal_name),
		"CharacterStats resource does not contain a Substat resource with internal name '{internal_name}'".format({
			"internal_name" : internal_name
		}))
	
	return _internal_substats[internal_name]

func get_wards() -> Array[StatusEffect]:
	return _wards

func get_alignment() -> Alignment:
	return _alignment

func sample_juxtometer_damage_dealt_curve(damage: int) -> float:
	return _juxtometer_damage_dealt_curve.sample(damage)
func sample_juxtometer_damage_taken_curve(damage: int) -> float:
	return _juxtometer_damage_taken_curve.sample(damage)

func _duplicate_stat_resources():
	for stat in _stats:
		var duplicated = stat.duplicate(true)
		_internal_stats[stat.get_internal_name()] = duplicated
func _duplicate_substat_resources():
	for substat in _substats:
		var duplicated = substat.duplicate(true)
		_internal_substats[substat.get_internal_name()] = duplicated
