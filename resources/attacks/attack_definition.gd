class_name AttackDefinition
extends Resource

signal attack_ended()

enum AttackType
{
	NONE,
	LIGHT,
	HEAVY
}

@export var _attack_name: String
@export_multiline var _attack_description: String

@export var _attack_type: AttackType = AttackType.NONE

@export var _attack_components: Array[AttackComponent]

func do(playable_character: PlayableCharacter) -> AttackInstance:
	var attack_instance = AttackInstance.new(0, null)
	
	for attack_component in _attack_components:
		attack_component._do(playable_character, self, attack_instance)
	
	return attack_instance

func end():
	attack_ended.emit()

func get_attack_name() -> String:
	return _attack_name
func get_attack_description() -> String:
	return _attack_description
func get_attack_type() -> AttackType:
	return _attack_type

func get_attack_components() -> Array[AttackComponent]:
	return _attack_components
func has_component(component_type) -> bool:
	for attack_component in _attack_components:
		if typeof(attack_component) == component_type:
			return true
	
	return false
