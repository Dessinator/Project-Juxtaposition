@tool
extends FSMState

@export_file("*.tscn") var _main_menu_scene_path: String

func _on_enter(_actor: Node, _blackboard: BTBlackboard) -> void:
	_load_main_menu_scene()

func _on_update(_delta: float, _actor: Node, _blackboard: BTBlackboard) -> void:
	pass

func _on_exit(_actor: Node, _blackboard: BTBlackboard) -> void:
	pass

func _load_main_menu_scene():
	SceneLoader.load_scene(_main_menu_scene_path)
