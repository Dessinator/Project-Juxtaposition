extends Area3D

@onready var _collision_shapes := get_children()

func _process(delta: float) -> void:
	if monitoring:
		for shape in _collision_shapes:
			shape.disabled = false
		return
	
	for shape in _collision_shapes:
			shape.disabled = true
