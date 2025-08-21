@tool
class_name AddNodeMenu
extends Window

signal light_attack_node_requested
signal heavy_attack_node_requested
signal dodge_node_requested
signal parry_node_requested
signal jux_dodge_node_requested
signal jux_parry_node_requested
signal juxtapose_node_requested

@onready var light_attack_button: Button = %LightAttackButton
@onready var heavy_attack_button: Button = %HeavyAttackButton
@onready var dodge_button: Button = %DodgeButton
@onready var parry_button: Button = %ParryButton
@onready var jux_dodge_button: Button = %JuxDodgeButton
@onready var jux_parry_button: Button = %JuxParryButton
@onready var juxtapose_button: Button = %JuxtaposeButton

func _on_light_attack_button_pressed() -> void:
	light_attack_node_requested.emit()
	hide()

func _on_heavy_attack_button_pressed() -> void:
	heavy_attack_node_requested.emit()
	hide()

func _on_dodge_button_pressed() -> void:
	dodge_node_requested.emit()
	hide()

func _on_parry_button_pressed() -> void:
	parry_node_requested.emit()
	hide()

func _on_jux_dodge_button_pressed() -> void:
	jux_dodge_node_requested.emit()
	hide()

func _on_jux_parry_button_pressed() -> void:
	jux_parry_node_requested.emit()
	hide()

func _on_juxtapose_button_pressed() -> void:
	juxtapose_node_requested.emit()
	hide()
