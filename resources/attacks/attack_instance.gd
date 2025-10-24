class_name AttackInstance
extends Resource

signal charge_attack_advance_requested
signal await_attack_phase_advance_input_requested
signal ignore_attack_phase_advance_input_requested
signal attack_concluded

var hitboxes: Array[Hitbox]

func emit_charge_attack_advance_requested():
	charge_attack_advance_requested.emit()
func emit_await_attack_phase_advance_input_requested():
	await_attack_phase_advance_input_requested.emit()
func emit_ignore_attack_phase_advance_input_requested():
	ignore_attack_phase_advance_input_requested.emit()
func emit_attack_concluded():
	attack_concluded.emit()
