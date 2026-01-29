class_name WorldUIObjectManager
extends Node

## will look for any nodes in the world_ui_objects group
## and allow access to the node through a dictionary.

var world_ui_objects: Dictionary[StringName, Array] = {}

func _ready() -> void:
	find_world_ui_objects()
	initialize_world_ui_objects()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## will fill the world_ui_objects Dictionary with any nodes in the
## "world_ui_objects" group that are children of this node's parent.
func find_world_ui_objects():
	for object in get_tree().get_nodes_in_group("world_ui_objects"):
		if not object.get_parent() == self.get_parent():
			continue
		
		if not world_ui_objects.has(object.name):
			world_ui_objects[StringName(object.name)] = [ object ]
			continue
		
		world_ui_objects[StringName(object.name)].append(object)

func initialize_world_ui_objects():
	for key in world_ui_objects.keys():
		var objects = world_ui_objects[key]
		for object in objects:
			var interface = object.get_node("WorldUIObjectInterface")
			interface.initialize()

func get_objects(by_name: StringName) -> Array:
	if not world_ui_objects.has(by_name):
		return []
	
	return world_ui_objects[by_name]

func return_all():
	for key in world_ui_objects.keys():
		var objects = world_ui_objects[key]
		for object in objects:
			var interface = object.get_node("WorldUIObjectInterface")
			interface.handle_return()

func _exit_tree() -> void:
	request_ready()
