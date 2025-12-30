@tool
class_name SubstatCurveVisualMarker
extends Node2D

const PLACEHOLDER_STAT_ABBREVIATION: String = "STAT"

@onready var _positive_modifier_line_2d: Line2D = %PositiveModifierLine2D
@onready var _negative_modifier_line_2d: Line2D = %NegativeModifierLine2D

@onready var _polygon2d: Polygon2D = %Polygon2D
@onready var _stat_abbreviation_label: Label = %StatAbbreviationLabel
@onready var _stat_value_label: Label = %StatValueLabel
@onready var _substat_modifier_value_label: Label = %SubstatModifierValueLabel

var _last_head_positions: Array[Vector2] = []

@export var available_area: Vector2 = Vector2(200, 200)
@export var left_padding: float
@export var right_padding: float
@export var top_padding: float
@export var bottom_padding: float

@export var tail_vertex_index: int = 3

@export var stat_abbreviation: String:
	set(value):
		stat_abbreviation = value

		if stat_abbreviation.is_empty():
			%StatAbbreviationLabel.text = PLACEHOLDER_STAT_ABBREVIATION
			return
		
		%StatAbbreviationLabel.text = stat_abbreviation
@export var stat_value: int:
	set(value):
		stat_value = value

		%StatValueLabel.text = str(stat_value)

@export var substat_modifier_value: float:
	set(value):
		substat_modifier_value = value

		var string = ""

		if substat_modifier_value == 0:
			%SubstatModifierValueLabel.text = string
			return

		if substat_modifier_value > 0:
			string += "+"

		%SubstatModifierValueLabel.text = string + str(snappedf(substat_modifier_value, 0.1))

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_marker_position(pos: Vector2):
	position = pos
	position = position + (Vector2.UP * substat_modifier_value)

	position.x = clampf(position.x, left_padding, available_area.x - right_padding)
	position.y = clampf(position.y, top_padding, available_area.y - bottom_padding)

	var tail_position = (Vector2.UP * substat_modifier_value) + (pos - position)
	%Polygon2D.polygon[tail_vertex_index] = tail_position
	if substat_modifier_value < 0:
			%NegativeModifierLine2D.points[0] = (pos - position)
			%NegativeModifierLine2D.points[1] = Vector2(tail_position.x, tail_position.y)
			%PositiveModifierLine2D.points[0].y = 0
			%PositiveModifierLine2D.points[1].y = 0
	elif substat_modifier_value > 0:
			%PositiveModifierLine2D.points[0] = (pos - position)
			%PositiveModifierLine2D.points[1] = Vector2(tail_position.x, tail_position.y)
			%NegativeModifierLine2D.points[0].y = 0
			%NegativeModifierLine2D.points[1].y = 0
	else:
		%NegativeModifierLine2D.points[0].y = 0
		%NegativeModifierLine2D.points[1].y = 0
		%PositiveModifierLine2D.points[0].y = 0
		%PositiveModifierLine2D.points[1].y = 0

	# _handle_marker_cutoff_prevention()

# func _handle_marker_cutoff_prevention():
	