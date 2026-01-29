class_name CharacterModel
extends Node3D


## emitted when an attack animation has requested hitbox to be
## spawned at target position.
signal request_spawn_hitbox_on_target

## emitted when an attack animation has requested a charge attack
## to be advanced.
signal request_charge_attack_advance

## emitted when an attack animation has requested input to advance
## to the next phase.
signal request_await_attack_phase_advance_input
## emitted when an attack animation has requested input to advance
## to be ignored (i.e., when the attack animation has ended before
## the player has made any input to advance).
signal request_ignore_attack_phase_advance_input
## emitted when an attack animation has concluded.
signal attack_concluded

@export var mesh_instance_3d: MeshInstance3D

## to be called by the CharacterModel's AnimationPlayer's tracks.
## calling this function will emit the request_spawn_hitbox_on_target
## signal, which will prompt the PlayableCharacterCombatManager to
## spawn a hitbox at a specified size on the current target.
func emit_request_spawn_hitbox_on_target():
	request_spawn_hitbox_on_target.emit()

## to be called by the CharacterModel's AnimationPlayer's tracks.
## calling this function will emit the request_charge_attack_advance signal,
## which will prompt the PlayableCharacterCombatManager to advance a charge
## attack and actually start the attack.
func emit_request_charge_attack_advance():
	request_charge_attack_advance.emit()

## to be called by the CharacterModel's AnimationPlayer's tracks.
## calling this function will emit the request_await_attack_phase_advance_input 
## signal, which will prompt the PlayableCharacterCombatManager to listen
## for input to advance to the next attack or return to idle.
func emit_request_await_attack_phase_advance_input():
	request_await_attack_phase_advance_input.emit()
## to be called by the CharacterModel's AnimationPlayer's tracks.
## calling this function will emit the request_ignore_attack_phase_advance_input
## signal, which will prompt the PlayableCharacterCombatManager to ignore
## input to advance to the next attack.
func emit_request_ignore_attack_phase_advance_input():
	request_ignore_attack_phase_advance_input.emit()

## to be called the CharacterModel's AnimationPlayer's tracks. calling this
## function will emit the attack_concluded signal, which will prompt the
## PlayableCharacter to return from the attack state it was in.
func emit_attack_concluded():
	attack_concluded.emit()
