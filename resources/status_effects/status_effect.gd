class_name StatusEffect extends Resource

# a Status Effect is a buff or debuff which makes temporary changes to an Actors stats.

signal applied(status_effect: StatusEffect)
signal stack_applied(status_effect: StatusEffect)
signal ticked(status_effect: StatusEffect)
signal stack_removed(status_effect: StatusEffect)
signal ended(status_effect: StatusEffect)

@export_category("Metadata")
@export var _name: String
@export var _icon: Texture2D
@export_multiline var _brief_description: String
@export_multiline var _long_description: String

enum StatusEffectType { TYPE_GENERAL, TYPE_BUFF, TYPE_DEBUFF }
enum StatusEffectDurationMode { MODE_IGNORE_NEW_STACK, MODE_PER_STACK, MODE_QUEUE_STACK, MODE_RESET_ON_NEW_STACK }
@export_category("Functional")
@export var _status_effect_type: StatusEffectType = StatusEffectType.TYPE_GENERAL
# how long the modifier will be in effect for
# 0 will be treated as infinite
@export var _duration_turns: int
# MODE_IGNORE_NEW_STACK: Status effect duration will not be modified when this status effect is stacked.
# MODE_PER_STACK: Status effect duration is per-stack.
# MODE_QUEUE_STACK: Status effect duration is determined by the number of stacks.
#					(e.x., if there are 6 stacks and this status effect lasts 2 turns, it will take 12 turns
#					for the status effect to end.)
# MODE_RESET_ON_NEW_STACK: Status effect duration is reset upon stacking.
@export var _duration_mode: StatusEffectDurationMode
@export var _status_effect_components: Array[StatusEffectComponent]

# the character that this modifier is attached to
var _affected_character: Character
# the stats resource from the original actor
var _stats: CharacterStats
# number of this same modifier affecting _affected_actor
var _stacks: Array = []

func get_status_effect_instance() -> Dictionary:
	var instance = {
		"metadata" 		 : {
			"name"				: _name,
			"icon"				: _icon,
			"brief_description"	: _brief_description,
			"long_description"	: _long_description
		},

		"functional"	 : {
			"type"				: _status_effect_type,
			"duration_turns"	: _duration_turns,
			"duration_mode"		: _duration_mode,
			"components"		: _status_effect_components,		
		},

		"affected_actor" : null,
		"attached_stats" : _stats,
		"stacks"		 : [],

		"on_stack_applied"		 : Signal(self, "stack_applied"),
		"on_ticked"		 		 : Signal(self, "ticked"),
		"on_stack_removed"		 : Signal(self, "stack_removed")
	}

	return instance

func set_stats(stats: CharacterStats):
	_stats = stats

static func get_turns_left_for_status_effect_instance(status_effect_instance: Dictionary) -> int:
	# if infinite, just return zero
	if status_effect_instance["functional"]["duration_turns"] == 0:
		return 0
	
	match status_effect_instance["functional"]["duration_mode"]:
		StatusEffectDurationMode.MODE_PER_STACK:
			var max = -1
			for stack in status_effect_instance["stacks"]:
				max = max(stack, max)
			return max
		StatusEffectDurationMode.MODE_QUEUE_STACK:
			var sum = 0
			for stack in status_effect_instance["stacks"]:
				sum += stack
			return sum
		_:
			# return the stack closest to 0
			var min = 999999
			for stack in status_effect_instance["stacks"]:
				min = min(stack, min)
			return min

func get_status_effect_name() -> String:
	return _name
func get_icon() -> Texture2D:
	return _icon
func get_brief_desc() -> String:
	return _brief_description
func get_long_desc() -> String:
	return _long_description

func get_status_effect_type() -> StatusEffectType:
	return _status_effect_type
func get_duration_mode() -> StatusEffectDurationMode:
	return _duration_mode

func get_duration_turns() -> int:
	return _duration_turns

func get_components() -> Array:
	return _status_effect_components
