class_name CharacterStatus
extends Status

signal max_stamina_modified(old: int, new: int)
signal stamina_modified(old: int, new: int)

signal juxtometer_modified(old: float, new: float)
signal juxtapose
signal normalize

const JUXTOMETER_MAX_READING: float = 100.00

const DEFENSE: StringName = &"defense"
const VITALITY: StringName = &"vitality"
const DAMAGE_RESISTANCE: StringName = &"damage_resistance"
const DEBUFF_RESISTANCE: StringName = &"debuff_resistance"
const BUFF_RETENTION: StringName = &"buff_retention"
const MAXIMUM_HEALTH: StringName = &"maximum_health"
const MAXIMUM_STAMINA: StringName = &"maximum_stamina"

var _character: Character
var _stats: CharacterStats

# stamina
var _max_stamina: int
var _stamina: int

# juxtometer
var _juxtometer: float = 0.00
var _is_juxtaposed: bool = false

func initialize(character: Character, stats: CharacterStats):
	_character = character
	_stats = stats
	
	var vitality_stat = _stats.get_stat(VITALITY)
	var vitality_value = vitality_stat.get_value(false)
	var max_health_stat = _stats.get_substat(MAXIMUM_HEALTH)
	var max_health_value = max_health_stat.sample(vitality_value, false)
	
	_set_max_health(max_health_value)
	_set_health(get_max_health())
	
	var max_stamina_stat = _stats.get_substat(MAXIMUM_STAMINA)
	var max_stamina_value = max_stamina_stat.sample(vitality_value, false)
	
	_set_max_stamina(max_stamina_value)
	_set_stamina(get_max_stamina())
	
	var defense_stat = _stats.get_stat(DEFENSE)
	var defense_value = defense_stat.get_value(false)
	var damage_resistance_stat = _stats.get_substat(DAMAGE_RESISTANCE)
	var debuff_resistance_stat = _stats.get_substat(DEBUFF_RESISTANCE)
	var buff_retention_stat = _stats.get_substat(BUFF_RETENTION)
	
	_damage_resistance = damage_resistance_stat.sample(defense_value, false)
	_debuff_resistance = debuff_resistance_stat.sample(defense_value, false)
	_buff_retention = buff_retention_stat.sample(defense_value, false)

# stamina
func exhaust(amount: int):
	if _is_dead:
		return
	
	_set_stamina(_stamina - amount)
func rest(amount: int):
	if _is_dead:
		return
	
	_set_stamina(_stamina + amount)

# juxtometer
func fill_juxtometer(amount: float):
	if _is_dead:
		return
	
	_set_juxtometer_reading(_juxtometer + amount)
func deplete_juxtometer(amount: float):
	if _is_dead:
		return
	
	_set_juxtometer_reading(_juxtometer - amount)

# status effects
func apply_status_effect(status_effect: StatusEffect, stacks: int = 1, ignore_dbrs: bool = false):
	if _is_dead:
		return

	var instance = status_effect.get_status_effect_instance()
	var status_effect_name = instance["metadata"]["name"]

	if not ignore_dbrs:
		if instance["functional"]["type"] == StatusEffect.StatusEffectType.TYPE_DEBUFF:
			var resisted = _handle_debuff_resistance()
			if resisted:
				return

	for i in range(stacks):
		var combined = _handle_combination(instance)
		if combined:
			print("combined")
			instance = combined

		if _status_effects.has(status_effect_name):
			_add_stacks_to_status_effect(_status_effects[status_effect_name], 1)
			continue
			
		_status_effects[status_effect_name] = instance
		instance["affected_character"] = _character
		status_effect_applied.emit(instance)
		_add_stacks_to_status_effect(_status_effects[status_effect_name], 1)

		for component in instance["functional"]["components"]:
			component.apply(instance, instance["affected_character"])

# setters and getters
func _set_max_stamina(value: int):
	var old = _max_stamina
	_max_stamina = value
	max_stamina_modified.emit(old, _max_stamina)
func _set_stamina(value: int):
	if _is_dead:
		return
	
	var old = _stamina
	if old == value:
		return
	
	if value > _max_stamina:
		value = _max_stamina
	if value < 0:
		value = 0
	
	_stamina = value
	stamina_modified.emit(old, _stamina)
func get_max_stamina() -> int:
	return _max_stamina
func get_stamina() -> int:
	return _stamina
func is_exhausted() -> bool:
	return _stamina <= 0
func is_stamina_max() -> bool:
	return not _stamina < _max_stamina

func _set_juxtometer_reading(value: float):
	if _is_dead:
		return
	
	var old = _juxtometer
	if old == value:
		return
	
	if value > JUXTOMETER_MAX_READING:
		value = JUXTOMETER_MAX_READING
	if value < 0:
		value = 0
	
	_juxtometer = snappedf(value, 0.01)
	juxtometer_modified.emit(old, _juxtometer)
func set_is_juxtaposed(value: bool):
	_is_juxtaposed = value
	if _is_juxtaposed:
		juxtapose.emit()
		return
	normalize.emit()
func is_juxtaposed() -> bool:
	return _is_juxtaposed
func get_juxtometer_reading() -> float:
	return _juxtometer
func is_juxtometer_empty() -> bool:
	return _juxtometer <= 0
func is_juxtometer_full() -> bool:
	return _juxtometer >= JUXTOMETER_MAX_READING
