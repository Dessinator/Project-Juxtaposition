class_name StatusEffectSelection extends Resource

@export var _status_effect: StatusEffect
@export var _ignore_bfrt_or_dbrs: bool
@export var _chance: float = 1.00
@export var _stacks: int = 1

func get_status_effect() -> StatusEffect:
    return _status_effect
func does_ignore_bfrt_or_dbrs() -> bool:
    return _ignore_bfrt_or_dbrs
func get_chance() -> float:
    return _chance
func get_stacks() -> int:
    return _stacks
