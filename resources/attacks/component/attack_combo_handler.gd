class_name AttackComboHandler
extends AttackComponent

@export var _sub_attacks: Array[AttackDefinition]

# -1 = combo has not started
var _current_sub_attack_index: int = -1

func initialize(attack: AttackDefinition) -> void:
	for i in range(_sub_attacks.size()):
		var sub_attack = _sub_attacks[i]
		
		var attack_combo_definitions = sub_attack.get_attack_components().filter(func(comp): return comp is AttackComboDefinition)
		assert(attack_combo_definitions.size() > 0, "Sub-Attack {attack_index} on AttackComboHandler {attack_name} needs an AttackComboDefinition!".format({
			"attack_index" : i,
			"attack_name" : attack.get_attack_name()
		}))
		
		#var possible_next_attacks = attack_combo_definitions[0].get_possible_next_attacks()
		#for j in range(possible_next_attacks.size()):
			#var possible_next_attack = possible_next_attacks[j]
			#
			#assert(_sub_attacks.has(possible_next_attack), "Possible Next Attack {possible_next_attack_index} on Attack {sub_attack_index} does not exist on AttackComboHandler {attack_name}".format({
				#"possible_next_attack_index" : j,
				#"sub_attack_index" : i,
				#"attack_name" : attack.get_attack_name()
			#}))

func _do(playable_character: PlayableCharacter, attack_definition: AttackDefinition, attack_instance: AttackInstance) -> void:
	_current_sub_attack_index += 1
	var sub_attack = _sub_attacks[_current_sub_attack_index]
	
	sub_attack.do(playable_character)
	sub_attack.attack_ended.connect(_handle_end.bind(attack_definition))

func _handle_end(attack_definition: AttackDefinition):
	_current_sub_attack_index = -1
	
	attack_definition.end()
