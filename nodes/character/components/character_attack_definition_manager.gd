class_name CharacterAttackDefinitionManager
extends Node

# responsible for holding a character's AttackDefinitions

@export var _light_attack: AttackDefinition
@export var _heavy_attack: AttackDefinition

func _initialize():
	_light_attack = _light_attack.duplicate()
	_heavy_attack = _heavy_attack.duplicate()

func get_light_attack() -> AttackDefinition:
	return _light_attack
func get_heavy_attack() -> AttackDefinition:
	return _heavy_attack
