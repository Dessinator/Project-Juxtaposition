class_name CharacterStatus
extends Resource

signal max_health_modified(old: int, new: int)
signal health_modified(old: int, new: int)
signal max_stamina_modified(old: int, new: int)
signal stamina_modified(old: int, new: int)

signal healed(amount: int, show_status_number: bool)
signal damaged(amount: int, crit: bool, show_status_number: bool)
signal died
signal revived

signal status_effect_applied(status_effect_instance: Dictionary)
signal status_effect_stack_applied(status_effect_instance: Dictionary)
signal status_effect_ticked(status_effect_instance: Dictionary)
signal status_effect_stack_removed(status_effect_instance: Dictionary)
signal status_effect_removed(status_effect_instance: Dictionary)
signal resisted_debuff
signal retained_buff

const DEFENSE: StringName = &"defense"
const VITALITY: StringName = &"vitality"
const DAMAGE_RESISTANCE: StringName = &"damage_resistance"
const DEBUFF_RESISTANCE: StringName = &"debuff_resistance"
const BUFF_RETENTION: StringName = &"buff_retention"
const MAXIMUM_HEALTH: StringName = &"maximum_health"
const MAXIMUM_STAMINA: StringName = &"maximum_stamina"

var _character: Character
var _stats: CharacterStats

# health
var _max_health: int
var _health: int

var _is_dead: bool = false

# stamina
var _max_stamina: int
var _stamina: int

# status effects
var _status_effects: Dictionary = {}

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

# damage
func damage(base_amount: int, crit: bool = false, addend: int = 0, show_damage_number: bool = false):
	var defense_stat = _stats.get_stat(DEFENSE)
	var defense_value = defense_stat.get_value(false)
	var damage_resistance_stat = _stats.get_substat(DAMAGE_RESISTANCE)
	var damage_resistance_value = damage_resistance_stat.sample(defense_value, false)
	
	var damage_negated = int((base_amount * damage_resistance_value) + 0.5)
	var true_damage = base_amount - damage_negated + addend
	_set_health(_health - true_damage)
	damaged.emit(true_damage, crit, show_damage_number)
func heal(amount: int, show_status_number: bool = false):
	_set_health(_health + amount)
	healed.emit(amount, show_status_number)
func revive(recover_health: int, recover_stamina: int):
	_is_dead = false
	_set_health(recover_health)
	_set_stamina(recover_stamina)
	revived.emit()
func die():
	_is_dead = true
	died.emit()

# stamina
func exhaust(amount: int):
	_set_stamina(_stamina - amount)
func rest(amount: int):
	_set_stamina(_stamina + amount)

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
		
func _add_stacks_to_status_effect(status_effect_instance: Dictionary, stacks: int):
	var stacks_array = status_effect_instance["stacks"]
	var duration = status_effect_instance["functional"]["duration"]
	for i in range(stacks):
		stacks_array.append(duration)
		
		if status_effect_instance["functional"]["duration_mode"] == StatusEffect.StatusEffectDurationMode.MODE_RESET_ON_NEW_STACK:
			for j in range(stacks_array.size()):
				stacks_array[j] = duration
		
		status_effect_stack_applied.emit(status_effect_instance)
func _tick_status_effect(status_effect_instance: Dictionary):
	var stacks_array = status_effect_instance["stacks"]

	for component in status_effect_instance["functional"]["components"]:
		component.tick(status_effect_instance, status_effect_instance["affected_character"])

	# tick status effect if it is meant to be infinite.
	if status_effect_instance["functional"]["duration"] == 0:
		status_effect_ticked.emit(status_effect_instance)
		return
	
	# update individual stack counters UNLESS _duration_mode == MODE_QUEUE_STACK OR _duration_turns == 0
	if (status_effect_instance["functional"]["duration_mode"] == StatusEffect.StatusEffectDurationMode.MODE_QUEUE_STACK):
		stacks_array[0] -= 1
	else:
		for i in range(stacks_array.size()):
			stacks_array[i] -= 1
	
	#status_effect_instance["on_ticked"].emit(status_effect_instance)
	status_effect_ticked.emit(status_effect_instance)

	var stacks_to_end = []
	for i in range(stacks_array.size()):
		if stacks_array[i] <= 0:
			stacks_to_end.append(i)
	for i in stacks_to_end:
		if stacks_array.is_empty():
			return
		_end_status_effect_stack(status_effect_instance, stacks_to_end[i])
func _end_status_effect_stack(status_effect_instance: Dictionary, stack_index: int):
	var affected_character = status_effect_instance["affected_character"]
	var stacks_array = status_effect_instance["stacks"]
	var components_array = status_effect_instance["functional"]["components"]

	match status_effect_instance["functional"]["duration_mode"]:
		StatusEffect.StatusEffectDurationMode.MODE_PER_STACK:
			_remove_stack_from_status_effect(status_effect_instance, stack_index)

			if not stacks_array.is_empty():
				return
			
			for component in components_array:
				component.end(status_effect_instance, affected_character)
		StatusEffect.StatusEffectDurationMode.MODE_QUEUE_STACK:
			_remove_stack_from_status_effect(status_effect_instance, stack_index)

			if not stacks_array.is_empty():
				return
			
			for component in components_array:
				component.end(status_effect_instance, affected_character)
		_:
			for i in range(stacks_array.size() - 1, -1, -1):
				_remove_stack_from_status_effect(status_effect_instance, i)
			
			for component in components_array:
				component.end(status_effect_instance, affected_character)
func _remove_stack_from_status_effect(status_effect_instance: Dictionary, stack_index: int):
	var stacks_array = status_effect_instance["stacks"]
	stacks_array.remove_at(stack_index)
	status_effect_stack_removed.emit(status_effect_instance)
	
	if stacks_array.size() > 0:
		return
		
	_clear_status_effect(status_effect_instance)
	
func remove_status_effect(status_effect_instance: Dictionary, stacks: int = 1, ignore_bfrt: bool = false):
	var status_effect_name = status_effect_instance["metadata"]["name"]

	if not _status_effects.has(status_effect_name):
		return
	
	var status_effect = _status_effects[status_effect_name]
	var stacks_array = status_effect["stacks"]
	
	for i in range(stacks):
		if not ignore_bfrt:
			if status_effect["functional"]["type"] == StatusEffect.StatusEffectType.TYPE_BUFF:
				var retained = _handle_buff_retention()
				if retained:
					continue
		
		stacks_array.remove_at(stacks_array.size() - 1)

func _clear_status_effect(status_effect_instance: Dictionary):
	var status_effect_name = status_effect_instance["metadata"]["name"]
	if not _status_effects.has(status_effect_name):
		return
	
	for i in range(_status_effects[status_effect_name]["stacks"].size() - 1, -1, -1):
		_remove_stack_from_status_effect(_status_effects[status_effect_name], i)

	status_effect_removed.emit(_status_effects[status_effect_name])
	_status_effects.erase(status_effect_name)
func _clear_all_status_effects():
	for status_effect_name in _status_effects.keys():
		var status_effect = _status_effects[status_effect_name]

		_clear_status_effect(status_effect)
		status_effect_removed.emit(status_effect)
		
	_status_effects.clear()

func _handle_debuff_resistance() -> bool:
	var defense_stat = _stats.get_stat(DEFENSE)
	var defense_value = defense_stat.get_value(false)
	var debuff_resistance_stat = _stats.get_substat(DEBUFF_RESISTANCE)
	var debuff_resistance_value = debuff_resistance_stat.sample(defense_value, false)
	
	var roll = randf()
	if roll < debuff_resistance_value:
		resisted_debuff.emit()
		return true
	return false

func _handle_buff_retention() -> bool:
	var defense_stat = _stats.get_stat(DEFENSE)
	var defense_value = defense_stat.get_value(false)
	var buff_retention_stat = _stats.get_substat(BUFF_RETENTION)
	var buff_retention_value = buff_retention_stat.sample(defense_value, false)

	var roll = randf()
	if roll < buff_retention_value:
		retained_buff.emit()
		return true
	return false

func _handle_combination(status_effect_instance: Dictionary):
	# search for any CombineRules first
	var combine_rules = status_effect_instance["functional"]["components"].filter(func(component): return component is CombineRule)
	if combine_rules.size() == 0:
		return null

	# if any CombineRule components found, see if any matching input status effect is active
	var matching_active_effects = []
	for rule in combine_rules:
		for rule_effect_name in rule.get_combination_rules().keys():
			if not _status_effects.has(rule_effect_name):
				continue
			
			matching_active_effects.append(_status_effects[rule_effect_name])
	if matching_active_effects.size() == 0:
		return null

	# combinations should happen with the last applied APPLICABLE status effect, usually the active status effect with
	# the greatest number of turns left.
	var last_applied_status_effect = matching_active_effects[0]

	for matching_active_effect in matching_active_effects:
		if StatusEffect.get_turns_left_for_status_effect_instance(matching_active_effect) > StatusEffect.get_turns_left_for_status_effect_instance(last_applied_status_effect):
			last_applied_status_effect = matching_active_effect

	# remove the other effect
	remove_status_effect(last_applied_status_effect, 1)

	var combination_result
	for rule in combine_rules:
		for rule_effect_name in rule.get_combination_rules().keys():
			if rule_effect_name == last_applied_status_effect["metadata"]["name"]:
				combination_result = rule.get_combination_rules()[last_applied_status_effect["metadata"]["name"]].get_status_effect_instance()
				break

	return combination_result

func tick_debuffs():
	for status_effect_name in _status_effects.keys():
		var status_effect_instance = _status_effects[status_effect_name]
		if status_effect_instance["functional"]["type"] != StatusEffect.StatusEffectType.TYPE_DEBUFF:
			continue
		_tick_status_effect(status_effect_instance)

func tick_general():
	for status_effect_name in _status_effects.keys():
		var status_effect_instance = _status_effects[status_effect_name]
		if status_effect_instance["functional"]["type"] != StatusEffect.StatusEffectType.TYPE_GENERAL:
			continue
		_tick_status_effect(status_effect_instance)

func tick_buffs():
	for status_effect_name in _status_effects.keys():
		var status_effect_instance = _status_effects[status_effect_name]
		if status_effect_instance["functional"]["type"] != StatusEffect.StatusEffectType.TYPE_BUFF:
			continue
		_tick_status_effect(status_effect_instance)



# setters and getters
func _set_max_health(value: int):
	var old = _max_health
	_max_health = value
	max_health_modified.emit(old, _max_health)
func _set_health(value: int):
	if _is_dead:
		return

	var old = _health
	if old == value:
		return
	
	if value > _max_health:
		value = _max_health
	elif value <= 0:
		value = 0

		die()
	
	_health = value
	health_modified.emit(old, _health)
func get_max_health() -> int:
	return _max_health
func get_health() -> int:
	return _health
func is_dead() -> bool:
	return _is_dead
func is_health_max() -> bool:
	return not _health < _max_health

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

func get_status_effects() -> Dictionary:
	return _status_effects
