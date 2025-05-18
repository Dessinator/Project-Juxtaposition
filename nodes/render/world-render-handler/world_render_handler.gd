extends Control

const PS1_RESOLUTION = Vector2i(320, 240)
const PS2_RESOLUTION = Vector2i(640, 480)
const PS3_RESOLUTION = Vector2i(960, 720)
const GAME_RESOLUTION = Vector2i(1280, 960)

const PS1_STRETCH_SHRINK = 4
const PS2_STRETCH_SHRINK = 3
const PS3_STRETCH_SHRINK = 2
const GAME_STRETCH_SHRINK = 1

const DEFAULT_COLOR_LIMIT = 12

@onready var _subviewport_container: SubViewportContainer = %SubViewportContainer
@onready var _subviewport: SubViewport = %SubViewport

func _ready():
	_preselect_resolution()
	_preselect_affine_mapping()
	_preselect_jitter_strength()
	_preselect_dithering()
	_preselect_limit_colors()
	
	SignalBus.render_resolution_changed.connect(_set_resolution)
	SignalBus.affine_mapping_changed.connect(_set_affine_mapping)
	SignalBus.jitter_strength_changed.connect(_set_jitter_strength)
	SignalBus.dithering_changed.connect(_set_dithering)
	SignalBus.limit_colors_changed.connect(_set_limit_colors)
	
	get_window()

func _preselect_resolution():
	var resolution = AppSettings.get_render_resolution()
	_set_resolution(resolution)
func _preselect_affine_mapping():
	var affine_mapping = AppSettings.get_affine_mapping()
	_set_affine_mapping(affine_mapping)
func _preselect_jitter_strength():
	var jitter_strength = AppSettings.get_jitter_strength()
	_set_jitter_strength(jitter_strength)
func _preselect_dithering():
	var dithering = AppSettings.get_dithering()
	_set_dithering(dithering)
func _preselect_limit_colors():
	var limit_colors = AppSettings.get_limit_colors()
	_set_limit_colors(limit_colors)

func _set_resolution(resolution: Vector2i):
	_subviewport.size_2d_override = resolution
	
	var nodes = get_tree().get_nodes_in_group("uses_psx_render_shader")
	for node in nodes:
		var shader_material = node.get_active_material(0) as ShaderMaterial
		shader_material.set_shader_parameter("resolution", resolution)
	
	if resolution == PS1_RESOLUTION:
		_subviewport_container.stretch = true
		_subviewport_container.stretch_shrink = PS1_STRETCH_SHRINK
		var shader_material = _subviewport_container.material as ShaderMaterial
		shader_material.set_shader_parameter("dither_size", PS1_STRETCH_SHRINK)
	elif resolution == PS2_RESOLUTION:
		_subviewport_container.stretch = true
		_subviewport_container.stretch_shrink = PS2_STRETCH_SHRINK
		var shader_material = _subviewport_container.material as ShaderMaterial
		shader_material.set_shader_parameter("dither_size", PS2_STRETCH_SHRINK)
	elif resolution == PS3_RESOLUTION:
		_subviewport_container.stretch = true
		_subviewport_container.stretch_shrink = PS3_STRETCH_SHRINK
		var shader_material = _subviewport_container.material as ShaderMaterial
		shader_material.set_shader_parameter("dither_size", PS3_STRETCH_SHRINK)
	elif resolution == GAME_RESOLUTION:
		_subviewport_container.stretch = true
		_subviewport_container.stretch_shrink = GAME_STRETCH_SHRINK
		var shader_material = _subviewport_container.material as ShaderMaterial
		shader_material.set_shader_parameter("dither_size", GAME_STRETCH_SHRINK)
		return
func _set_affine_mapping(affine_mapping: bool):
	var nodes = get_tree().get_nodes_in_group("uses_psx_render_shader")
	for node in nodes:
		var shader_material = node.get_active_material(0) as ShaderMaterial
		shader_material.set_shader_parameter("affine_mapping", affine_mapping)
func _set_jitter_strength(jitter_strength: float):
	var nodes = get_tree().get_nodes_in_group("uses_psx_render_shader")
	for node in nodes:
		var shader_material = node.get_active_material(0) as ShaderMaterial
		shader_material.set_shader_parameter("jitter", jitter_strength)
func _set_dithering(dithering: bool):
	var shader_material = _subviewport_container.material as ShaderMaterial
	shader_material.set_shader_parameter("dithering", dithering)
func _set_limit_colors(limit_colors: bool):
	var shader_material = _subviewport_container.material as ShaderMaterial
	shader_material.set_shader_parameter("enabled", limit_colors)
