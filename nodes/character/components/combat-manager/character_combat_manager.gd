class_name CharacterCombatManager
extends Node

var _attack_history # : Array[CharacterAttack]

@export var _combos: CharacterCombo

func _start_recording_attacks():
	pass
func _stop_recording_attacks():
	pass
func _clear_attack_history():
	_attack_history = []

func do_attack(attack):
	pass

func _handle_combo_case():
	pass
