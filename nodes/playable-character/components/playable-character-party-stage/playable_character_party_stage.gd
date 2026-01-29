class_name PlayableCharacterPartyStage
extends Node3D

@onready var camera: Camera3D = %Camera3D

@onready var _pedestals: Array[Node3D] = [
	%Pedestal1,
	%Pedestal2,
	%Pedestal3
]
@onready var nonplayable_characters: Array[NonplayableCharacter] = [
	%PartyStageNonplayableCharacter1,
	%PartyStageNonplayableCharacter2,
	%PartyStageNonplayableCharacter3
]

@onready var _default_camera_marker: Marker3D = %DefaultCameraMarker
@onready var _default_camera_target: Marker3D = %DefaultCameraTarget
@onready var _quick_select_camera_marker: Marker3D = %QuickSelectCameraMarker
@onready var _quick_select_camera_target: Marker3D = %QuickSelectCameraTarget

var current_party: Party:
	set(value):
		var old_party = current_party
		current_party = value

		# shouldn't ever happen but just in case
		if current_party == null:
			return
		
		for nonplayable_character in nonplayable_characters:
			nonplayable_character.nonplayable_character_character_container.clear_characters()

		for i in range(current_party.member_internal_names.size()):
			var internal_name = current_party.member_internal_names[i]
			if internal_name.is_empty():
				continue

			var character_packet = Characters.get_character_packet(internal_name)
			
			nonplayable_characters[i].nonplayable_character_character_container.add_character_packet(character_packet)

@export var camera_transition_duration: float


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func focus_camera_pedestal(pedestal_index: int):
	var pedestal = _pedestals[pedestal_index]
	var camera_marker = pedestal.get_node("CameraMarker")
	var camera_target = pedestal.get_node("CameraTarget")
	
	var dir = (camera_target.global_position - camera_marker.global_position).normalized()
	var front_dir = (camera.global_position + Vector3.FORWARD - camera.global_position)
	var rotation = Quaternion(front_dir, dir).get_euler()

	var position_tween: Tween = create_tween()
	position_tween.tween_property(camera, "global_position", camera_marker.global_position, camera_transition_duration).set_ease(Tween.EaseType.EASE_OUT)
	var rotation_tween: Tween = create_tween()
	rotation_tween.tween_property(camera, "rotation", rotation, camera_transition_duration).set_ease(Tween.EaseType.EASE_OUT)

func focus_quick_select():
	var dir = (_quick_select_camera_target.global_position - _quick_select_camera_marker.global_position).normalized()
	var front_dir = (camera.global_position + Vector3.FORWARD - camera.global_position)
	var rotation = Quaternion(front_dir, dir).get_euler()
	
	var position_tween: Tween = create_tween()
	position_tween.tween_property(camera, "global_position", _quick_select_camera_marker.global_position, camera_transition_duration).set_ease(Tween.EaseType.EASE_OUT)
	var rotation_tween: Tween = create_tween()
	rotation_tween.tween_property(camera, "rotation", rotation, camera_transition_duration).set_ease(Tween.EaseType.EASE_OUT)

func unfocus_camera():
	var dir = (_default_camera_target.global_position - _default_camera_marker.global_position).normalized()
	var front_dir = (camera.global_position + Vector3.FORWARD - camera.global_position)
	var rotation = Quaternion(front_dir, dir).get_euler()
	
	var position_tween: Tween = create_tween()
	position_tween.tween_property(camera, "global_position", _default_camera_marker.global_position, camera_transition_duration).set_ease(Tween.EaseType.EASE_OUT)
	var rotation_tween: Tween = create_tween()
	rotation_tween.tween_property(camera, "rotation", rotation, camera_transition_duration).set_ease(Tween.EaseType.EASE_OUT)
