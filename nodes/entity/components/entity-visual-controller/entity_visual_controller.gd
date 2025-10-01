class_name EntityVisualController
extends Node

const DAMAGE_CRIT_STATUS_NUMBER_SCENE = preload("res://nodes/status-number/prefabs/damage_crit_status_number.tscn")
const DAMAGE_STATUS_NUMBER_SCENE = preload("res://nodes/status-number/prefabs/damage_status_number.tscn")
const HEAL_STATUS_NUMBER_SCENE = preload("res://nodes/status-number/prefabs/heal_status_number.tscn")

@onready var _status_interface: StatusInterface = %StatusInterface
@onready var _targeted_indicator: TargetedIndicator = %TargetedIndicator

@export var _health_bar: EntityFloatingHealthBar

func initialize() -> void:
	var status = _status_interface.get_status()
	
	status.health_modified.connect(_on_health_modified)
	status.max_health_modified.connect(_on_max_health_modified)
	status.damaged.connect(_on_damaged)
	status.healed.connect(_on_healed)
	status.died.connect(_on_died)
	
	_health_bar.status_bar.set_max_value(status.get_max_health())
	_health_bar.status_bar.set_current_value(status.get_health())

func _on_health_modified(_old: int, new: int):
	_health_bar.status_bar.set_current_value(new)
func _on_max_health_modified(_old: int, new: int):
	_health_bar.status_bar.set_max_value(new)
func _on_damaged(damage_instance: DamageInstance):
	if not damage_instance.spawn_damage_number:
		return
	_handle_damage_status_number_instantiation(damage_instance.base_damage, damage_instance.is_crit)
func _on_healed(heal_instance: HealInstance):
	if not heal_instance.spawn_heal_number:
		return
	_handle_heal_status_number_instantiation(heal_instance.heal)
func _on_died():
	_health_bar.visible = false
	_targeted_indicator.visible = false

func _handle_damage_status_number_instantiation(amount: int, crit: bool):
	if crit:
		var instance = DAMAGE_CRIT_STATUS_NUMBER_SCENE.instantiate()
		instance.value = amount
		get_parent().add_child(instance)
		return
	
	var instance = DAMAGE_STATUS_NUMBER_SCENE.instantiate()
	instance.value = amount
	get_parent().add_child(instance)
func _handle_heal_status_number_instantiation(amount: int):
	var instance = HEAL_STATUS_NUMBER_SCENE.instantiate()
	instance.value = amount
	get_parent().add_child(instance)

func _on_trackable_target_entered_target_range() -> void:
	_health_bar.visible = true
func _on_trackable_target_exited_target_range() -> void:
	_health_bar.visible = false
	
