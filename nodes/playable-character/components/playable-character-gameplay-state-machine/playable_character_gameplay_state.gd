@tool
class_name PlayableCharacterGameplayState
extends FSMState

@export var _gameplay_action_visual_packedscene: PackedScene

@onready var _transitions: Array = get_children()

# Executes after the state is entered.
func _on_enter(_actor: Node, _blackboard: BTBlackboard) -> void:
	pass

# Executes every _process call, if the state is active.
func _on_update(_delta: float, _actor: Node, _blackboard: BTBlackboard) -> void:
	pass

# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: BTBlackboard) -> void:
	pass
