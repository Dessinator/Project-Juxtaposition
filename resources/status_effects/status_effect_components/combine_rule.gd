class_name CombineRule extends StatusEffectComponent

# defines a rule under which multiple status effects can combine.

## requires the parant status effect AND these keys, values are considered outputs.
@export var _combination_rules: Dictionary

func get_combination_rules() -> Dictionary:
    return _combination_rules