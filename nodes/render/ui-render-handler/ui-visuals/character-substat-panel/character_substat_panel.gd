@tool
class_name CharacterSubstatPanel
extends PanelContainer

const PLACEHOLDER_SUBSTAT_ABBREVIATION: String = "SUB STT"
const PLACEHOLDER_SUBSTAT_NAME: String = "Substat"
const PLACEHOLDER_MINIMUM_X_AXIS_STRING: String = "minX"
const PLACEHOLDER_MAXIMUM_X_AXIS_STRING: String = "maxX"
const PLACEHOLDER_MINIMUM_Y_AXIS_STRING: String = "minY"
const PLACEHOLDER_MAXIMUM_Y_AXIS_STRING: String = "maxY"

@onready var _icon_texture_rect: TextureRect = %IconTextureRect
@onready var _icon_separator: VSeparator = %IconVSeparator

@onready var _abbreviation_label: Label = %AbbreviationLabel
@onready var _name_label: Label = %NameLabel
@onready var _value_label: Label = %ValueLabel
@onready var _modifier_value_label: Label = %ModifierValueLabel

@onready var _advanced_details_panel_container: PanelContainer = %AdvancedDetailsPanelContainer

@onready var _description_label: Label = %DescriptionLabel

@onready var _curve_visualizer_line_2d: Line2D = %CurveVisualizerLine2D
@onready var _substat_curve_visual_marker: SubstatCurveVisualMarker = %SubstatCurveVisualMarker


@export var icon: Texture2D:
	set(v):
		icon = v

		if icon == null:
			%IconTextureRect.texture = null
			%IconTextureRect.visible = false
			%IconVSeparator.visible = false
			return
		
		%IconTextureRect.visible = true
		%IconVSeparator.visible = true
		%IconTextureRect.texture = icon

@export var substat_abbreviation: String:
	set(v):
		substat_abbreviation = v

		if substat_abbreviation.is_empty():
			%AbbreviationLabel.text = PLACEHOLDER_SUBSTAT_ABBREVIATION
			return
		
		%AbbreviationLabel.text = substat_abbreviation
@export var substat_name: String:
	set(v):
		substat_name = v

		if substat_name.is_empty():
			%NameLabel.text = "({substat_name})".format({"substat_name" : PLACEHOLDER_SUBSTAT_NAME})
			return
		
		%NameLabel.text = "({substat_name})".format({"substat_name" : substat_name})

@export var source_stat_abbreviation: String:
	set(v):
		source_stat_abbreviation = v

		_update_substat_curve_visual()
@export var source_stat_value: int:
	set(v):
		source_stat_value = v

		_update_substat_curve_visual()

@export var value: float:
	set(v):
		value = v
		
		%ValueLabel.text = str(snappedf(value, 0.1))
@export var modifier_value: float:
	set(v):
		modifier_value = v

		_update_substat_curve_visual()

		var string = ""

		if modifier_value == 0:
			%ModifierValueLabel.text = string
			return

		if modifier_value > 0:
			string += "+"

		%ModifierValueLabel.text = string + str(snappedf(modifier_value, 0.1))

@export_multiline var description: String:
	set(v):
		description = v

		%DescriptionLabel.text = description

@export var substat_curve: Curve:
	set(v):
		substat_curve = v
		_update_substat_curve_visual()
@export var curve_resolution: int = 20:
	set(v):
		curve_resolution = v
		_update_substat_curve_visual()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# little hack to update the curve visualization in editor
	if Engine.is_editor_hint():
		if substat_curve == null:
			%SubstatCurveVisualMarker.set_marker_position(Vector2(0, 200))
			return
		
		%CurveVisualizerLine2D.points = _generate_substat_curve_points(substat_curve)
		%SubstatCurveVisualMarker.set_marker_position(_get_substat_curve_marker_position(substat_curve))
		%SubstatCurveVisualMarker.substat_modifier_value = modifier_value
		value = snappedf(substat_curve.sample(source_stat_value), 0.1)

func _update_substat_curve_visual():
	if not is_node_ready() and not Engine.is_editor_hint():
		await ready

	%SubstatCurveVisualMarker.stat_abbreviation = source_stat_abbreviation
	%SubstatCurveVisualMarker.stat_value = source_stat_value
	%SubstatCurveVisualMarker.substat_modifier_value = modifier_value

	if substat_curve == null:
		%CurveVisualizerLine2D.points = PackedVector2Array()

		%MinXAxisLabel.text = PLACEHOLDER_MINIMUM_X_AXIS_STRING
		%MaxXAxisLabel.text = PLACEHOLDER_MAXIMUM_X_AXIS_STRING
		%MinYAxisLabel.text = PLACEHOLDER_MINIMUM_Y_AXIS_STRING
		%MaxYAxisLabel.text = PLACEHOLDER_MAXIMUM_Y_AXIS_STRING
		return

	%CurveVisualizerLine2D.points = _generate_substat_curve_points(substat_curve)
	%SubstatCurveVisualMarker.set_marker_position(_get_substat_curve_marker_position(substat_curve))

	%MinXAxisLabel.text = str(snappedf(substat_curve.min_domain, 0.001))
	%MaxXAxisLabel.text = str(snappedf(substat_curve.max_domain, 0.001))
	%MinYAxisLabel.text = str(snappedf(substat_curve.min_value, 0.001))
	%MaxYAxisLabel.text = str(snappedf(substat_curve.max_value, 0.001))

func _generate_substat_curve_points(curve: Curve) -> PackedVector2Array:
	var curve_2d = Curve2D.new()
	
	for i in range(curve_resolution):
		var curve_x_pos = remap(i, 0, curve_resolution, curve.min_domain, curve.max_domain)
		var y_pos = curve.sample(curve_x_pos)
		
		var point_x_position = remap(i, 0, curve_resolution - 1, 0, 200)
		var point_y_position = -remap(y_pos, curve.min_value, curve.max_value, 0, 200) + 200

		var point_position = Vector2(point_x_position, point_y_position)
		curve_2d.add_point(point_position)
	
	var points = curve_2d.tessellate()
	return points

func _get_substat_curve_marker_position(curve: Curve) -> Vector2:
	var substat_value = curve.sample(source_stat_value)

	var x_position = remap(source_stat_value, 0, 9999, 0, 200)
	var y_position = -remap(substat_value, curve.min_value, curve.max_value, 0, 200) + 200

	var position = Vector2(x_position, y_position)
	return position

func _on_expand_button_toggled(toggled_on: bool) -> void:
	_advanced_details_panel_container.visible = toggled_on
