class_name CharacterButton
extends Node3D

signal button_pressed

@onready var node_area: Area3D = %Area3D

# Used for checking if the mouse is inside the Area3D.
var is_mouse_inside = false

var character_model: CharacterModel

@export var character_container: NonplayableCharacterCharacterContainer

func _ready():
	character_container.character_added.connect(_on_character_container_character_added)
	character_container.character_removed.connect(_on_character_container_character_removed)

	node_area.input_ray_pickable = !character_container.get_characters().is_empty()

	node_area.mouse_entered.connect(_mouse_entered_area)
	node_area.mouse_exited.connect(_mouse_exited_area)
	node_area.input_event.connect(_mouse_input_event)

	handle_grab_character_model()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_character_container_character_added(character: Character):
	handle_grab_character_model()
	node_area.input_ray_pickable = true
func _on_character_container_character_removed(character: Character):
	handle_grab_character_model()
	node_area.input_ray_pickable = false

func _mouse_entered_area():
	is_mouse_inside = true
	handle_highlight_character(true)
func _mouse_exited_area():
	is_mouse_inside = false
	handle_highlight_character(false)

func _mouse_input_event(_camera: Camera3D, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int):
	event = event as InputEventMouseButton
	if event == null:
		return
	
	if not event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		return
	if not event.pressed:
		return
	
	button_pressed.emit()

func handle_grab_character_model():
	var current_character = character_container.get_current_character()

	# no character has been selected for the slot yet.
	if not current_character:
		return

	character_model = character_container.get_current_character().get_character_model()

func handle_highlight_character(highlight: bool):
	if not character_model:
		return

	if highlight:
		character_model.mesh_instance_3d.set_instance_shader_parameter("_Color", Color.WHITE) 
		return
	
	character_model.mesh_instance_3d.set_instance_shader_parameter("_Color", Color.BLACK) 

func _exit_tree() -> void:
	if not is_mouse_inside:
		return
	handle_highlight_character(false)
