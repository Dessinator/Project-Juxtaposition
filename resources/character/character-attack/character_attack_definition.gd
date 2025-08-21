@tool
class_name CharacterAttackDefinition
extends Resource

signal attack_ended()

#enum AttackType
#{
	#NONE,
	#LIGHT,
	#HEAVY
#}

@export var _internal_name: StringName
@export var _readable_name: String
@export_multiline var _description: String

#@export var _attack_type: AttackType = AttackType.NONE

@export var _attack_components: Array[CharacterAttackDefinitionComponent]

func do(playable_character: PlayableCharacter) -> AttackInstance:
	var attack_instance = AttackInstance.new(0, null)
	
	if _attack_components.is_empty():
		end()
		return attack_instance
	
	for attack_component in _attack_components:
		attack_component._do(playable_character, self, attack_instance)
	
	return attack_instance

func end():
	attack_ended.emit()

func get_internal_name() -> StringName:
	return _internal_name
func get_readable_name() -> String:
	return _readable_name
func get_description() -> String:
	return _description
#func get_attack_type() -> AttackType:
	#return _attack_type

#func get_attack_components() -> Array[CharacterAttackDefinitionComponent]:
	#return _attack_components
#func has_component(component_type) -> bool:
	#for attack_component in _attack_components:
		#if typeof(attack_component) == component_type:
			#return true
	#
	#return false
