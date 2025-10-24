@tool
class_name Hurtbox
extends Area3D

@onready var _collision_shape_3d: CollisionShape3D = %CollisionShape3D

@export var status_interface: StatusInterface
@export var shape: BoxShape3D:
	set(value):
		shape = value
		%CollisionShape3D.shape = shape

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_entered(area: Area3D) -> void:
	# the only areas that should be able to interact with
	# a hurtbox is a hitbox (due to the collision layers)
	# but just in case we'll run this check.
	var hitbox = area as Hitbox
	if not hitbox:
		return
	
	if not hitbox.try_consume():
		return
	
	var damage_instance = hitbox.consume()
	var status = status_interface.get_status()
	status.damage(damage_instance)
