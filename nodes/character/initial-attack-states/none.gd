@tool
extends CharacterAttackState

# used whenever the character isnt currently preforming a gameplay action that does not
# affect the character's attacks (i.e., walking, idle, etc.)

# Executes after the state is entered.
func _on_enter(_actor: Node, _blackboard: BTBlackboard) -> void:
	pass


# Executes every _process call, if the state is active.
func _on_update(_delta: float, _actor: Node, _blackboard: BTBlackboard) -> void:
	if Input.is_action_just_pressed("light_attack"):
		get_parent().fire_event("start_light_series")
		return
	if Input.is_action_just_pressed("heavy_attack"):
		get_parent().fire_event("start_heavy_series")
		return

# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: BTBlackboard) -> void:
	pass


# Add custom configuration warnings
# Note: Can be deleted if you don't want to define your own warnings.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array = []

	warnings.append_array(super._get_configuration_warnings())

	# Add your own warnings to the array here

	return warnings
